# Copyright 2014, Dell
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


class Deployment < ActiveRecord::Base
  
  after_create   :add_initial_snapshop
  before_create  :set_parent
  before_destroy :release_nodes    # also prevent deleting if deployment is a system deployment

  validates_uniqueness_of   :name, :case_sensitive => false, :message => I18n.t("db.notunique", :default=>"Name item must be unique")
  validates_format_of       :name, :with=>/\A[a-zA-Z][_a-zA-Z0-9]*\z/, :message => I18n.t("db.lettersnumbers", :default=>"Name limited to [_a-zA-Z0-9]")

  has_one           :snapshot,           :dependent => :destroy
  alias_attribute   :head,                :snapshot

  belongs_to        :parent,              :class_name => "Deployment"
  has_many          :nodes

  scope             :system_root,         -> { where(:system=>true) }   # cannot be named 'system' because of internal method name conflicts

  # active includes nothing being committed
  def active?
    head.active?
  end

  def committed?
    head.committed?
  end

  def proposed?
    head.proposed?
  end

  def state
    head.state
  end

  # commit the current proposal (cannot be done if there is a committed proposal)
  def commit
    head.commit
  end

  # is this a system deployment?
  def system?
    read_attribute("system")
  end

  # available roles to be added to deployment
  def available_roles
    candidates = Role.active
    # except, don't include roles that we've already got
    in_use = head.roles
    candidates - in_use
  end

  # available nodes that could be used in the deployment
  def available_nodes
    self.nodes
  end

  # Lookup the roles available for the deployment, use the Proposal then Active 
  def roles
    head.roles
  end

  private

  # if we delete a deployment, then reset the nodes to be from the system deployment
  def release_nodes

    if system
      # cannot delete a system deployment
      return false
    else
      # else release all the nodes in the deployment (assign to the system deployment)
      system = Deployment.system_root.last
      nodes.each do |n|
        n.deployment_id = system.id
        n.save!
      end
      return true
    end

  end

  def set_parent
    # 1st system deployment is a special case
    if Deployment.system_root.count == 0
      # Make it a system deployment write attribute because we don't allow direct access to system    
      self[:system]= true
    else
      # system is a safe fall back (unless we are system)
      self.parent_id ||= (Deployment.system_root.first.id rescue nil)
    end
  end

  # all deployments must have a snapshot
  def add_initial_snapshop
    s = Snapshot.create! :name=>self.name, :deployment_id=>self.id
    self.snapshot_id = s.id
    self.save!
  end

end
