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
class CreateRoleRequires < ActiveRecord::Migration
  def change
    create_table :role_requires do |t|
      t.belongs_to  :role,            null: false
      t.string      :requires,        null: false, index: true
      t.integer     :required_role_id, foreign_key: { references: :roles, name: "role_requires_fk" }
      t.timestamps
    end
    add_index(:role_requires, [:role_id, :requires], unique: true)

    create_table :role_require_attribs do |t|
      t.belongs_to  :role
      t.string      :attrib_name
      t.string      :attrib_at
      t.timestamps
    end
    add_index(:role_require_attribs, [:role_id, :attrib_name], :unique => true)
    # Create a view that allows us to recursively get all the parents
    # and children of a given role.  Holes in the graph will have NULL
    # in place of parent_id.

    create_view :all_role_requires, "
with recursive arr (role_id, required_role_id, required_role_name) as (
    select role_id, required_role_id, requires from role_requires
    union
    select arr.role_id, rr.required_role_id, rr.requires
    from arr, role_requires rr
    where rr.requires  = arr.required_role_name)
    select role_id, required_role_id, required_role_name from arr;"

    create_view :all_role_requires_paths, "
with recursive arrp (child_name, parent_name, path) as (
    select r.name, rr.requires, ARRAY[r.name::text,rr.requires::text]
    from role_requires rr, roles r where r.id = rr.role_id
    union
    select arrp.child_name, rr.requires, arrp.path || rr.requires::text
    from arrp, roles r, role_requires rr
    where r.id = rr.role_id AND r.name = arrp.parent_name)
    select child_name, parent_name, path from arrp;"
  end

end
