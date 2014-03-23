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
class CreateNodeRoles < ActiveRecord::Migration
  def change
    create_table :node_roles do |t|
      t.belongs_to  :deployment,        null: false, index: true
      t.belongs_to  :role,              null: false, index: true
      t.belongs_to  :node,              null: false, index: true
      t.integer     :state,             null: false, default: NodeRole::PROPOSED
      t.integer     :cohort,            null: false, default: 0
      t.integer     :run_count,         null: false, default: 0
      t.string      :status,            null: true   # expected for error, blocked, transistioning
      t.text        :runlog,            null: false, default: ""
      t.boolean     :available,         null: false, default: true
      t.integer     :order,             default: 10000
      t.json        :proposed_data,     null: false, default: { expr: "'{}'::json" }
      t.json        :committed_data,    null: true
      t.json        :sysdata,           null: false, default: { expr: "'{}'::json" }
      t.json        :wall,              null: false, default: { expr: "'{}'::json" }
      t.timestamps
    end
    #natural key
    add_index(:node_roles, [:role_id, :node_id], unique: true)

    create_table :node_role_pcms, id: false do |t|
      t.integer     :parent_id, foreign_key: { references: :node_roles, name: 'parent_fk' }, index: true
      t.integer     :child_id, foreign_key: { references: :node_roles, name: 'child_fk' }, index: true
    end
    add_index(:node_role_pcms, [:parent_id, :child_id], unique: true)

    # Create a view that expands all node_role_pcms to include all the
    # recursive parents and children of a node.
    # This is very postgresql 9.3 specific.
    create_view :node_role_all_pcms, "
with recursive p (child_id, parent_id) as (
      select child_id, parent_id from node_role_pcms
      union
      select p.child_id, pcm.parent_id from node_role_pcms pcm, p
      where pcm.child_id = p.parent_id)
      select child_id, parent_id from p;"
  end
end
