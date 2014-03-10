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

class Role < ActiveRecord::Base

  class Role::MISSING_DEP < Exception
  end

  class Role::MISSING_JIG < Exception
  end

  validates_uniqueness_of   :name,  :scope => :barclamp_id
  validates_format_of       :name,  :with=>/\A[a-zA-Z][-_a-zA-Z0-9]*\z/, :message => I18n.t("db.lettersnumbers", :default=>"Name limited to [_a-zA-Z0-9]")

  after_commit :resolve_requires_and_jig

  belongs_to      :barclamp
  belongs_to      :jig,               :foreign_key=>:jig_name, :primary_key=>:name
  has_many        :role_requires,     :dependent => :destroy
  has_many        :active_role_requires, -> { where("required_role_id IS NOT NULL") }, class_name: "RoleRequire"
  has_many        :role_requires_children, class_name: "RoleRequire", foreign_key: :requires, primary_key: :name
  has_many        :parents, through: :active_role_requires, source: :parent
  has_many        :children, through: :role_requires_children, source: :role
  has_many        :role_require_attribs, :dependent => :destroy
  has_many        :attribs,           :dependent => :destroy
  has_many        :wanted_attribs,    :through => :role_require_attribs, :class_name => "Attrib", :source => :attrib
  has_many        :node_roles,        :dependent => :destroy
  has_many        :deployment_roles,  :dependent => :destroy
  alias_attribute :requires,          :role_requires

  scope           :library,            -> { where(:library=>true) }
  scope           :implicit,           -> { where(:implicit=>true) }
  scope           :discovery,          -> { where(:discovery=>true) }
  scope           :bootstrap,          -> { where(:bootstrap=>true) }
  scope           :server,             -> { where(:server => true) }
  scope           :active,             -> { joins(:jig).where(["jigs.active = ?", true]) }
  scope           :all_cohorts,        -> { active.order("cohort ASC, name ASC") }
  scope           :all_cohorts_desc,   -> { active.order("cohort DESC, name ASC") }


  # incremental update (merges with existing)
  def template_update(val)
    Role.transaction do
      self.template = self.template.deep_merge(val)
      save!
    end
  end

  # State Transistion Overrides

  def on_error(node_role, *args)
    Rails.logger.debug "No override for #{self.class.to_s}.on_error event: #{node_role.role.name} on #{node_role.node.name}"
  end

  def on_active(node_role, *args)
    Rails.logger.debug "No override for #{self.class.to_s}.on_active event: #{node_role.role.name} on #{node_role.node.name}"
  end

  def on_todo(node_role, *args)
    Rails.logger.debug "No override for #{self.class.to_s}.on_todo event: #{node_role.role.name} on #{node_role.node.name}"
  end

  def on_transition(node_role, *args)
    Rails.logger.debug "No override for #{self.class.to_s}.on_transition event: #{node_role.role.name} on #{node_role.node.name}"
  end

  def on_blocked(node_role, *args)
    Rails.logger.debug "No override for #{self.class.to_s}.on_blocked event: #{node_role.role.name} on #{node_role.node.name}"
  end

  def on_proposed(node_role, *args)
    Rails.logger.debug "No override for #{self.class.to_s}.on_proposed event: #{node_role.role.name} on #{node_role.node.name}"
  end

  # Event triggers for node creation and destruction.
  # roles should override if they want to handle node addition
  def on_node_create(node)
    true
  end

  # Event triggers for node creation and destruction.
  # roles should override if they want to handle node destruction
  def on_node_delete(node)
    true
  end

  # Event hook that will be called every time a node is saved if any attributes changed.
  # Roles that are interested in watching nodes to see what has changed should
  # implement this hook.
  def on_node_change(node)
    true
  end

  # Event hook that is called whenever a new deployment role is bound to a deployment.
  # Roles that need do something on a per-deployment basis should override this
  def on_deployment_create(dr)
    true
  end

  # Event hook that is called whenever a deployment role is deleted from a deployment.
  def on_deployment_delete(dr)
    true
  end

  def noop?
    jig.name.eql? 'noop'
  end

  def name_i18n
    I18n.t(name, :default=>name, :scope=>'common.roles')
  end

  def name_safe
    name_i18n.gsub("-","&#8209;").gsub(" ","&nbsp;")
  end

  def update_cohort
    Role.transaction do
      c = (parents.maximum("cohort") || -1)
      if c >= cohort
        Rails.logger.info("Role: #{name}: Updating cohort from #{cohort} to #{c + 1}")
        update_column(:cohort,  c + 1)
      end
    end
    children.where('cohort <= ?',cohort).each do |child|
      Rails.logger.info("Role: #{name}: Asking child role #{child.name} to update its cohort")
      child.update_cohort
    end
  end

  def depends_on?(other)
    return false if self.id == other.id
    rents = parents
    tested = Hash.new
    loop do
      return false if rents.empty?
      new_parents = []
      rents.each do |parent|
        next if tested[parent.id] == true
        raise "Role dependency graph for #{self.barclamp.name}:#{name} is circular!" if parent.id == self.id
        return true if parent.id == other.id
        tested[parent.id] = true
        new_parents << parent.parents
      end
      rents = new_parents.flatten.reject{|i|tested[i.id]}
    end
    raise "Cannot happen examining dependencies for #{name} -> #{other.name}"
  end

  # Make sure there is a deployment role for ourself in the snapshot.
  def add_to_snapshot(snap)
    # make sure there's a deployment role before we add a node role
    if DeploymentRole.snapshot_and_role(snap, self).size == 0
      Rails.logger.info("Role: Adding deployment role #{name} to #{snap.name}")
      args = ActionController::Parameters.new(:role_id=>self.id,
                                              :snapshot_id=>snap.id,
                                              :data=>self.template).permit!
      DeploymentRole.create!(args)
    end
  end

  def find_noderoles_for_role(role,snap)
    csnap = snap
    loop do
      Rails.logger.info("Role: Looking for role '#{role.name}' binding in '#{snap.deployment.name}' deployment")
      pnrs = NodeRole.peers_by_role(csnap,role)
      return pnrs unless pnrs.empty?
      csnap = (csnap.deployment.parent.snapshot rescue nil)
      break if csnap.nil?
    end
    Rails.logger.info("Role: No bindings for #{role.name} in #{snap.deployment.name} or any parents.")
    []
  end

  def add_to_node(node)
    add_to_node_in_snapshot(node,node.deployment.head)
  end

  # Bind a role to a node in a snapshot.
  def add_to_node_in_snapshot(node,snap)
    # Roles can only be added to a node of their backing jig is active.
    unless active?
      # if we are testing, then we're going to just skip adding and keep going
      if Jig.active('test')
        Rails.logger.info("Role: Test mode allows us to coerce role #{name} to use the 'test' jig instead of #{jig_name} when it is not active")
        self.jig = Jig.find_by(name: 'test')
        self.save
      else
        raise MISSING_JIG.new("Role: role '#{name}' cannot be added to node '#{node.name}' without '#{jig_name}' being active!")
      end
    end
    
    # If we are already bound to this node in a snapshot, do nothing.
    res = NodeRole.find_by(node_id: node.id, role_id: self.id)
    return res if res
    Rails.logger.info("Role: Trying to add #{name} to #{node.name}")

    # First pass throug the parents -- we just create any needed parent noderoles.
    # We will actually bind them after creating the noderole binding.
    role_requires.each do |role_req|
      raise "Parent role #{role_req.requires} for #{name} does not exist!" unless role_req.resolved?
      parent = role_req.parent
      pnrs = find_noderoles_for_role(parent,snap)
      if pnrs.empty? || (parent.implicit && !pnrs.any?{|nr|nr.node_id == node.id})
        # If there are none, or the parent role has the implicit flag,
        # then bind the parent to ourself as well.
        # This logic will need to grow into bind the parent to the best suited
        # noderole in the current deployment eventually.
        Rails.logger.info("Role: Parent #{parent.name} not bound in scope, binding it to #{node.name} in #{snap.deployment.name}")
        parent.add_to_node_in_snapshot(node,snap)
      end
    end
    # At this point, all the parent noderoles we need are bound.
    # make sure that we also have a deployment role, then
    # create ourselves and bind our parents.
    NodeRole.transaction do
      add_to_snapshot(snap)
      res = NodeRole.create!({ :node => node,
                              :role => self,
                              :snapshot => snap,
                              :cohort => 0})
      Rails.logger.info("Role: Creating new noderole #{res.name}")
      # Second pass through our parent array.  Since we created all our
      # parent noderoles earlier, we can just concern ourselves with creating the bindings we need.
      parents.each do |parent|
        pnrs = find_noderoles_for_role(parent,snap)
        if parent.cluster
          # If the parent role has a cluster flag, then all of the found
          # parent noderoles will be bound to this one.
          Rails.logger.info("Role: Parent #{parent.name} of role #{name} has the cluster flag, binding all instances in deployment #{pnrs[0].deployment.name}")
          pnrs.each do |pnr|
            res.add_parent(pnr)
          end
        else
          # Prefer a parent noderole from the same node we are on, otherwise
          # just pick one at random.
          pnr = pnrs.detect{|nr|nr.node_id == node.id} ||
            pnrs[Random.rand(pnrs.length)]
          res.add_parent(pnr)
        end
      end
      # If I am a new noderole binding for a cluster node, find all the children of my peers
      # and bind them too.
      if self.cluster
        NodeRole.peers_by_role(snap,self).each do |peer|
          peer.children.each do |c|
            c.add_parent(res)
            c.deactivate
            c.save!
          end
        end
      end
      res.save!
    end
    res.reload
    res
  end

  def jig
    Jig.where(["name = ?",jig_name]).first
  end
  def active?
    j = jig
    return false unless j
    j.active
  end

  def <=>(other)
    return 0 if self.id == other.id
    self.cohort <=> other.cohort
  end

  private

  def resolve_requires_and_jig
    # Find all of the RoleRequires that refer to us,
    # and resolve them.  This will also update the cohorts if needed.
    role_requires_children.where(required_role_id: nil).each do |rr|
      rr.resolve!
    end
    return true unless jig && jig.client_role &&
      !RoleRequire.exists?(role_id: id,
                           requires: jig.client_role_name)
    # If our jig has already been loaded and it has a client role,
    # create a RoleRequire for it.
    RoleRequire.create!(role_id: id,
                        requires: jig.client_role_name)
  end

end
