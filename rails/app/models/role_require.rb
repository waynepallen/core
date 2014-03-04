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

class RoleRequire < ActiveRecord::Base

  belongs_to      :role
  belongs_to      :parent, class_name: Role, foreign_key: "required_role_id"
  alias_attribute :upstream, :parent

  before_create :enforce_acyclic

  after_create :resolve_requires

  def resolved?
    !required_role_id.nil?
  end

  def resolve!
    return if resolved?
    Rails.logger.info("RoleRequire: Trying to resolve #{requires} to a Role for #{role.name}")
    r = Role.find_by(name: self.requires)
    return unless r
    Rails.logger.info("RoleRequire: #{requires} resolves to role ID #{r.id}")
    update_column(:required_role_id, r.id)
    role.update_cohort
  end


  private

  # If there is a path in the graph from requires back to role_id,
  # then allowing this RoleRequire to be created would make the role graph
  # cyclic, and that is Not Allowed.
  def enforce_acyclic
    target_role = Role.find(role_id)
    source_role = Role.find_by(name: requires)
    Rails.logger.info("RoleRequire: Testing to see if having #{target_role.name} depend on #{requires} is OK")
    # If our source role has not been added yet, then there is no way we can
    # tell if adding this RoleRequires will result in a cyclic graph.
    # However, in that case the cycle will be detected when the role that
    # requires refers to adds its own RoleRequires, so we don't have to worry
    # about it here in any case.
    return true if source_role.nil?
    # Iterate over all of the parents of source_role until we either:
    # * Have no more parents to look at, in which case the graph is acyclic, or
    # * We find target_role, in which case adding ourself would create a cyclic
    #   graph.  If that happens, we will die with an exception.
    parent_reqs = source_role.role_requires
    until parent_reqs.empty? do
      Rails.logger.info("RoleRequire: Examining #{parent_reqs.inspect}")
      new_parent_reqs = []
      parent_reqs.each do |parent_req|
        if target_role.name == parent_req.requires
          # Well, that is that.  Nothing to do but die.
          raise("RoleRequire: Making #{target_role.name} depend on #{requires} makes the role graph cyclic through #{parent_req.role.name}")
        elsif parent_req.resolved?
          new_parent_reqs += parent_req.parent.role_requires
        end
      end
      parent_reqs = new_parent_reqs.uniq
    end
    # Creating this RoleRequire will not make the craph cyclic,
    # as far as we can tell.
    true
  end

  def resolve_requires
    resolve!
  end

end
