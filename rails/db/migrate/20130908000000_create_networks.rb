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

class CreateNetworks < ActiveRecord::Migration
  def change
    create_table "networks" do |t|
      t.references   :deployment
      t.string       :name,       null: false, index: { unique: true }
      t.string       :description,null: true
      t.integer      :order,      null: false, default: 1000
      t.integer      :vlan,       null: false, default: 0
      t.boolean      :use_vlan,   null: false, default: false
      t.boolean      :use_bridge, null: false, default: false
      t.integer      :team_mode,  null: false, default: 5
      t.boolean      :use_team,   null: false, default: false
      t.string       :v6prefix
      # This contains abstract interface names seperated by a comma.
      # It could be normalized, but why bother for now.
      t.string       :conduit,    null: false
      t.timestamps
    end

    create_table "network_routers" do |t|
      t.references   :network
      t.string       :address,    null: false
      t.integer      :pref,       null: false, default: 65536
      t.timestamps
    end

    create_table "network_ranges" do |t|
      t.string       :name,       null: false
      t.references   :network
      # Both of these should also be CIDRs.
      t.string       :first,      null: false
      t.string       :last,       null: false
      t.timestamps
    end
    add_index "network_ranges", [:network_id, :name], unique: true

    create_table "network_allocations" do |t|
      t.references   :node
      t.references   :network
      t.references   :network_range
      t.string       :address,    null: false, index: { unique: true }
      t.timestamps
    end
  end
end
