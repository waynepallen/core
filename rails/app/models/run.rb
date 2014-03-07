# Copyright 2013, Dell
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Run < ActiveRecord::Base

  belongs_to :node
  belongs_to :node_role

  scope :runnable,   -> { where(:running => false).sort{|a,b| a.sort_id <=> b.sort_id} }
  scope :running,    -> { where(:running => true) }
  scope :running_on, ->(node_id) { running.where(:node_id => node_id) }
  scope :deletable,  -> { where("id in (select r.id from runs r INNER JOIN node_roles nr
          ON r.node_role_id = nr.id
          where NOT ((nr.state = #{NodeRole::TRANSITION}) OR
         (nr.state in (#{NodeRole::TODO}, #{NodeRole::ACTIVE}) AND NOT r.running)))") }

  def sort_id
    [node_role.cohort, node_role_id, id]
  end

  def self.locked_transaction(&block)
    begin
      Run.transaction(isolation: :serializable) do
        ActiveRecord::Base.connection.execute("LOCK TABLE runs")
        yield if block_given?
      end
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error("Run: Deadlock detected, retrying: #{e.message}")
      retry
    end
  end

  def self.empty?
    Run.locked_transaction do
      deletable.destroy_all
      Run.all.count == 0
    end
  end

  # Queue up a job to run.
  # Run.enqueue should only be called when you want to enqueue a noderole
  # that is in a state other than TODO, as those will be picked up by Run.run!
  # The main callers of this should mostly be events called from role triggers.
  def self.enqueue(nr)
    raise "cannot enqueue a nil node_role!" if nr.nil?
    Run.locked_transaction do
      deletable.destroy_all
      unless nr.runnable? &&
          ([NodeRole::ACTIVE, NodeRole::TODO, NodeRole::TRANSITION].member?(nr.state))
        Rails.logger.debug("Run: #{nr.name} is NOT enqueueable/runnable [nr.state #{nr.state} is Active/Todo/Trans && node.available #{nr.node.available} && node.alive #{nr.node.alive} && jig.active #{nr.role.jig.active}]")
      else
        current_run = Run.where(:node_id => nr.node_id).first
        if nr.todo? && !current_run.nil?
          Rails.logger.debug("Run: #{nr.name} in TODO and #{current_run.node_role.name} is already enqueued on #{nr.node.name}")
        else
          if current_run
            Rails.logger.info("Run: Enqueing #{nr.name} after #{current_run.node_role.name}")
          else
            Rails.logger.info("Run: Enqueing #{nr.name}")
          end
          Run.create!(:node_id => nr.node_id,
                      :node_role_id => nr.id)
        end
      end
    end
    run!
  end

  # Run up to maxjobs jobs, enqueuing runnable noderoles in TODO as it goes.
  def self.run!(maxjobs=10)
    jobs = {}
    Run.locked_transaction do
      deletable.destroy_all
      Rails.logger.debug("Run: Queue: (start) #{Run.all.map{|j|"Job: #{j.id}: running:#{j.running}: #{j.node_role.name}: state #{j.node_role.state}"}}")
      running = Run.running.count
      # Look for enqueued runs and schedule at most one per node to go.
      Run.runnable.each do |j|
        break if jobs.length + running >= maxjobs
        if jobs[j.node_id] || Run.exists?(node_id: j.node_id, running: true)
          Rails.logger.debug("Run: Skipping #{j.id} due to something else running on #{j.node.name}.")
        else
          Rails.logger.info("Run: Enqueing #{j.id}")
          j.running = true
          j.save!
          jobs[j.node_id] = j
        end
      end

      # Find any runnable noderoles and see if they can be enqueued.
      # The logic here will only enqueue a noderole of the node does not
      # already have a noderole enqueued.
      NodeRole.runnable.order("cohort ASC, id ASC").each do |nr|
        break if jobs.length + running >= maxjobs
        if jobs[nr.node_id] || Run.exists?(node_id: nr.node_id)
          Rails.logger.debug("Run: Skipping #{nr.name} due to something already queued on #{nr.node.name}")
        else
          Rails.logger.info("Run: Enqueing #{nr.name}")
          jobs[nr.node_id] = Run.create!(:node_id => nr.node_id,
                              :node_role_id => nr.id,
                              :running => true)
        end
      end
    end
    return if jobs.length == 0
    # Now that we have things that are runnable, loop through them to see
    # what we can actually run.
    jobs.values.each do |j|
      j.node_role.state = NodeRole::TRANSITION
      if j.node_role.role.destructive && j.node_role.run_count > 0
        Rails.logger.info("Run: #{j.node_role.name} is destructive and has already run.")
        j.node_role.state = NodeRole::ACTIVE
        j.node_role.save!
        j.destroy
        next
      end
      # Take a snapshot of the data we want to hand to the jig's run method.
      # We do this so that the jig gets fed data that is consistent for this point
      # in time, as opposed to picking up whatever is lying around when delayed_jobs
      # gets around to actually doing its thing, which may not be what we expect.
      begin
        run_data = {}
        NodeRole.transaction do
          j.node_role.runlog = ""
          j.node_role.save!
          run_data = j.node_role.jig.stage_run(j.node_role)
        end
        j.node_role.jig.delay(:queue => "NodeRoleRunner").run_job(j,run_data)
      rescue Exception => e
        NodeRole.transaction do
          j.node_role.runlog = j.node_role.runlog << "EXCEPTION:\n#{e.message}\n#{e.backtrace.join("\n")}"
          Rails.logger.error(j.node_role.runlog)
          j.node_role.state = NodeRole::ERROR
          j.node_role.save!
        end
      end
    end
    Rails.logger.info("Run: #{jobs.length} handled this pass, #{Run.running.count} in delayed_jobs")
    begin
      # log queue state
            Rails.logger.debug("Run: Queue: (end) #{Run.all.map{|j|"Job: #{j.id}: running:#{j.running}: #{j.node_role.name}: state #{j.node_role.state}"}}")
    rescue
      # catch node_role is nil (exposed in simulator runs)
      Run.all.each { |j| raise "you cannot run job #{j.id} with missing node #{j.node_id} and node_role #{j.node_role_id} information.  This is likely a garbage collection issue!" if j.node_role.nil? }
    end
    return jobs.length
  end
end
