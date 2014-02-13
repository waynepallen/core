# Copyright 2011, Dell
# Copyright 2012, SUSE Linux Products GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied
# See the License for the specific language governing permissions and
# limitations under the License
#
# This recipe sets up Apache and TFTP servers.

node.normal["crowbar"]["provisioner"]["server"]["name"]=node.name
v4addr=node.address("admin",IP::IP4)
v6addr=node.address("admin",IP::IP6)
node.normal["crowbar"]["provisioner"]["server"]["v4addr"]=v4addr.addr if v4addr
node.normal["crowbar"]["provisioner"]["server"]["v6addr"]=v6addr.addr if v6addr
node.normal["crowbar"]["provisioner"]["server"]["proxy"]="#{v4addr.addr}:8123"
web_port = node["crowbar"]["provisioner"]["server"]["web_port"]
provisioner_web="http://#{v4addr.addr}:#{web_port}"
node.normal["crowbar"]["provisioner"]["server"]["webserver"]=provisioner_web


# Once the local proxy service is set up, we need to use it.
proxies = {
  "http_proxy" => "http://#{node["crowbar"]["provisioner"]["server"]["proxy"]}",
  "https_proxy" => "http://#{node["crowbar"]["provisioner"]["server"]["proxy"]}",
  "no_proxy" => (["127.0.0.1","::1"] + node.all_addresses.map{|a|a.network.to_s}.sort).join(",")
}


node.set["apache"]["listen_ports"] = [ node["crowbar"]["provisioner"]["server"]["web_port"], 8123 ]
include_recipe "apache2"
include_recipe "apache2::mod_ssl"
include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_http"
include_recipe "apache2::mod_proxy_connect"
apache_module "ssl"
apache_module "cache"
apache_module "disk_cache"

template "#{node["apache"]["dir"]}/sites-available/provisioner.conf" do
  path "#{node["apache"]["dir"]}/vhosts.d/provisioner.conf" if node["platform"] == "suse"
  source "base-apache.conf.erb"
  mode 0644
  variables(:docroot => node["crowbar"]["provisioner"]["server"]["root"],
            :port => node["crowbar"]["provisioner"]["server"]["web_port"],
            :logfile => "#{node["apache"]["log_dir"]}/provisioner-access_log",
            :errorlog => "#{node["apache"]["log_dir"]}/provisioner-error_log")
  notifies :reload, resources(:service => "apache2")
end
template "#{node["apache"]["dir"]}/sites-available/proxy.conf" do
  path "#{node["apache"]["dir"]}/vhosts.d/proxy.conf" if node["platform"] == "suse"
  source "proxy-apache.conf.erb"
  mode 0644
  variables(:port => 8123,
            :logfile => "#{node["apache"]["log_dir"]}/proxy-access_log",
            :errorlog => "#{node["apache"]["log_dir"]}/proxy-error_log",
            :allowed_clients => ["127.0.0.1","::1"] + node.all_addresses.map{|a|a.network.to_s}.sort,
            :upstream_proxy => ( node["crowbar"]["provisioner"]["server"]["upstream_proxy"] || "" rescue ""),
            :no_proxy => (["127.0.0.1","::1"] + node.all_addresses.map{|a|a.network.to_s}.sort).join(" "),
            :no_cache => node.addresses("admin")
            )
  notifies :reload, resources(:service => "apache2")
end
apache_site "provisioner.conf"
apache_site "proxy.conf"

template "/etc/environment" do
  source "environment.erb"
  variables(:values => proxies)
  action :nothing
  subscribes :create, "service[apache2]"
end

template "/etc/profile.d/proxy.sh" do
  source "proxy.sh.erb"
  variables(:values => proxies)
  action :nothing
  subscribes :create, "service[apache2]"
end

case node["platform"]
when "redhat","centos"
  template "/etc/yum.conf" do
    source "yum.conf.erb"
    action :nothing
    subscribes :create, "service[apache2]"
    variables(
              :distro => node["platform"],
              :proxy => proxies["http_proxy"]
              )
  end
end

# Set up the TFTP server as well.
case node["platform"]
when "ubuntu", "debian"
  package "tftpd-hpa"
when "redhat","centos"
  package "tftp-server"
when "suse"
  package "tftp"
end

case node["platform"]
when "suse"
  service "tftp" do
    enabled true
    if node["platform_version"].to_f >= 12.3
      provider Chef::Provider::Service::Systemd
      service_name "tftp.socket"
      action [ :enable, :start ]
    else
      # on older releases just enable, don't start (xinetd takes care of it)
      action [ :enable ]
    end
  end
  service "xinetd" do
    running true
    enabled true
    action [ :enable, :start ]
  end unless node["platform_version"].to_f >= 12.3
when "redhat","centos"
  template "/etc/xinetd.d/tftp" do
    source "xinetd.tftp.erb"
    variables(:tftproot => node["crowbar"]["provisioner"]["server"]["root"])
    mode 0644
    user "root"
    group "root"
    notifies :restart, "service[xinetd]"
  end
  service "xinetd" do
    action [:enable, :start]
  end
when "ubuntu"
  service "tftpd-hpa" do
    action [ :enable ]
  end
  template "/etc/default/tftpd-hpa" do
    source "tftpd-ubuntu.erb"
    mode 0644
    user "root"
    group "root"
    variables(
              :address => "0.0.0.0:69",
              :tftproot => node["crowbar"]["provisioner"]["server"]["root"]
              )
    notifies :restart, resources(:service => "tftpd-hpa")
  end
else
  raise "Cannot set up TFTP on #{node[platform]}"
end

