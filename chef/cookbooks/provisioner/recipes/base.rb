# Copyright 2011, Dell
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

package "ipmitool" do
  package_name "OpenIPMI-tools" if node[:platform] =~ /^(redhat|centos)$/
  action :install
end

directory "/root/.ssh" do
  owner "root"
  group "root"
  mode "0700"
  action :create
end

node[:crowbar][:access_keys] = {}

ruby_block "re-read the key file" do
  block do
    str = %x{cat /root/.ssh/id_rsa.pub}.chomp
    node[:crowbar][:root_pub_key] = str
    node.save
    node[:crowbar][:access_keys][node.name] = str
  end
  action :nothing
end

execute "build root key" do
  command "ssh-keygen -t rsa -f /root/.ssh/id_rsa -N \"\""
  not_if do ::File.exists?("/root/.ssh/id_rsa.pub") end
  notifies :create, "ruby_block[re-read the key file]", :immediately
end

template "/root/.ssh/authorized_keys" do
  owner "root"
  group "root"
  mode "0700"
  action :create
  source "authorized_keys.erb"
  variables(:keys => node[:crowbar][:access_keys])
end

config_file = "/etc/default/chef-client"
config_file = "/etc/sysconfig/chef-client" if node[:platform] =~ /^(redhat|centos)$/

cookbook_file config_file do
  owner "root"
  group "root"
  mode "0644"
  action :create
  source "chef-client"
end

