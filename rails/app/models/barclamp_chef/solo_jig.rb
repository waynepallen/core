# Copyright 2013, Dell
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#

require 'json'
require 'fileutils'

class BarclampChef::SoloJig < Jig

  def make_run_list(nr)
    runlist = Array.new
    runlist << "recipe[barclamp]"
    runlist << "recipe[ohai]"
    runlist << "recipe[utils]"
    runlist << "role[#{nr.role.name}]"
    runlist << "recipe[crowbar-hacks::solo-saver]"
    Rails.logger.info("Chef Solo: discovered run list: #{runlist}")
    return runlist
  end

  def stage_run(nr)
    chef_path = File.join(nr.barclamp.source_path, 'chef-solo')
    unless File.directory?(chef_path)
      raise("No Chef data at #{chef_path}")
    end
    paths = ["#{chef_path}/roles", "#{chef_path}/data_bags", "#{chef_path}/cookbooks"].select{|d|File.directory?(d)}.join(' ')
    # This needs to be replaced by rsync.
    out,err,ok = nr.node.scp_to(paths,"/var/chef","-r")
    raise("Chef Solo jig run for #{nr.name} failed to copy Chef information from #{paths.inspect}\nOut: #{out}\nErr: #{err}") unless ok.success?
    return {
      "name" => "crowbar_baserole",
      "default_attributes" => super(nr),
      "override_attributes" => {},
      "json_class" => "Chef::Role",
      "description" => "Crowbar role to provide default attribs for this run",
      "chef-type" => "role",
      "run_list" => make_run_list(nr)
    }
  end

  def run (nr,data)
    local_tmpdir = %x{mktemp -d /tmp/local-chefsolo-XXXXXX}.strip
    chef_path = File.join(nr.barclamp.source_path, 'chef-solo')
    role_json = File.join(local_tmpdir,"crowbar_baserole.json")
    node_json = File.join(local_tmpdir,"node.json")
    File.open(role_json,"w") do |f|
      f.write(JSON.pretty_generate(data))
    end
    File.open(node_json,"w") do |f|
      JSON.dump({"run_list" => "role[crowbar_baserole]"},f)
    end
    if nr.role.respond_to?(:jig_role) && !File.exists?("#{chef_path}/roles/#{nr.role.name}.rb")
      # Create a JSON version of the role we will need so that chef solo can pick it up
      File.open("#{local_tmpdir}/#{nr.role.name}.json","w") do |f|
        JSON.dump(nr.role.jig_role(nr),f)
      end
      out,err,ok = nr.node.scp_to("#{local_tmpdir}/#{nr.role.name}.json","/var/chef/roles/#{nr.role.name}.json")
      unless ok.success?
        Rails.logger.error("Chef Solo jig: #{nr.name}: failed to copy dynamic role to target")
        nr.runlog = "Out: #{out}\nErr:#{err}"
        nr.state = NodeRole::ERROR
        return finish_run(nr)
      end
    end
    out,err,ok = nr.node.scp_to(role_json, "/var/chef/roles/crowbar_baserole.json")
    unless ok.success?
      Rails.logger.error("Chef Solo jig: #{nr.name}: failed to copy node attribs to target")
      nr.runlog = "Out: #{out}\nErr:#{err}"
      nr.state = NodeRole::ERROR
      return finish_run(nr)
    end
    out,err,ok = nr.node.scp_to(node_json, "/var/chef/node.json")
    unless ok.success?
      Rails.logger.error("Chef Solo jig: #{nr.name}: failed to copy node to target")
      nr.runlog = "Out: #{out}\nErr:#{err}"
      nr.state = NodeRole::ERROR
      return finish_run(nr)
    end
    out,err,ok = nr.node.ssh("chef-solo -j /var/chef/node.json")
    unless ok.success?
      Rails.logger.error("Chef Solo jig run for #{nr.name} failed")
      nr.runlog = "Out: #{out}\nErr:#{err}"
      nr.state = NodeRole::ERROR
      return finish_run(nr)
    end
    nr.runlog = out
    node_out_json = File.join(local_tmpdir, "node-out.json")
    out,err,ok = nr.node.scp_from("/var/chef/node-out.json",local_tmpdir)
    unless ok.success?
      Rails.logger.error("Chef Solo jig run for #{nr.name} did not copy attributes back #{res}")
      nr.state = NodeRole::ERROR
      return finish_run(nr)
    end
    from_node = JSON.parse(IO.read(node_out_json))
    Node.transaction do
      discovery = nr.node.discovery
      discovery["ohai"] = from_node["automatic"]
      nr.node.discovery = discovery
      nr.node.save!
    end
    nr.wall = from_node["normal"]
    nr.state = ok ? NodeRole::ACTIVE : NodeRole::ERROR
    finish_run(nr)
  end
end
    
