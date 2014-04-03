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

class BarclampProvisioner::DockerSetup < Role

  def on_node_create(node)
    rerun_my_noderoles
  end

  def on_node_change(node)
    rerun_my_noderoles
  end

  def on_node_delete(node)
    rerun_my_noderoles
  end

  def rerun_my_noderoles
    docker_clients = {}
    Role.transaction do
      Role.find_by!(name: "crowbar-docker-node").nodes.each do |node|
        docker_clients[node.name] = {
          "addresses" => node.addresses.map{|a|a.to_s},
          "image" => "ubuntu:12.04",
          "os_token" => "ubuntu-12.04",
          "bootenv" => "local"
        }
      end
    end
    # this gets the client list sent to the jig implementing the DHCP database role
    new_sysdata = {
      "crowbar" =>{
        "dhcp" => {
          "clients" => docker_clients
        }
      }
    }
    to_enqueue = []
    NodeRole.transaction do
      node_roles.committed.each do |nr|
        next if nr.sysdata == new_sysdata
        nr.sysdata = new_sysdata
        nr.save!
        to_enqueue << nr
      end
    end
    to_enqueue.each { |nr| Run.enqueue(nr) }
  end
end
