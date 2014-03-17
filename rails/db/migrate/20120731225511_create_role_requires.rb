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
      t.foreign_key :roles
      t.string      :requires,        null: false
      t.integer     :required_role_id
      t.foreign_key :roles, name: "role_requires_fk", column: 'required_role_id'
      
      t.timestamps
    end
    add_index(:role_requires, [:role_id, :requires], unique: true)
    add_index(:role_requires, [:requires],           unique: false)

    create_table :role_require_attribs do |t|
      t.belongs_to  :role
      t.foreign_key :roles
      t.string      :attrib_name
      t.string      :attrib_at
      t.timestamps
    end
    add_index(:role_require_attribs, [:role_id, :attrib_name], :unique => true)
    # Create a view that allows us to recursively get all the parents
    # and children of a given role.  Holes in the graph will have NULL
    # in place of parent_id.
    execute "
create or replace recursive view all_role_requires (role_id, required_role_id, required_role_name) as
    select role_id, required_role_id, requires from role_requires
    union
    select arr.role_id, rr.required_role_id, rr.requires
    from all_role_requires arr, role_requires rr
    where rr.role_id  = arr.required_role_id;"

    execute "
create or replace recursive view all_role_require_paths (child_name, parent_name, path) as
    select r.name, rr.requires, ARRAY[r.name::text,rr.requires::text]
    from role_requires rr, roles r where r.id = rr.role_id
    union
    select arr.child_name, rr.requires, arr.path || rr.requires::text
    from all_role_require_paths arr, roles r, role_requires rr
    where r.id = rr.role_id AND r.name = arr.parent_name;"
  end

end
