#
# Cookbook Name:: crowbar-bootstrap
# Recipe:: default
#
# Copyright (C) 2014 Dell, Inc.

crowbar_yml = "/opt/opencrowbar/core/crowbar.yml"
unless File.exists?(crowbar_yml)
  raise "No crowbar checkout to bootstrap!"
end

prereqs = YAML.load(File.open(crowbar_yml))

os_token="#{node["platform"]}-#{node["platform_version"]}"

os_pkg_type = case node["platform"]
              when "debian","ubuntu" then "debs"
              when "centos","redhat","opensuse","suse","fedora" then "rpms"
              else
                raise "Cannot figure out what package type we should use!"
              end
Chef::Log.debug("os_token: #{os_token}, os_pkg_type: #{os_pkg_type}")

unless prereqs["os_support"].member?(os_token)
  raise "Cannot install crowbar on #{os_token}!  Can only install on one of #{prereqs["os_support"].join(" ")}"
end

repos = []
pkgs = []

# Find all the upstream repos and packages we will need.
if prereqs[os_pkg_type] && prereqs[os_pkg_type][os_token]
  repos << prereqs[os_pkg_type][os_token]["repos"]
  pkgs << prereqs[os_pkg_type][os_token]["build_pkgs"]
  pkgs << prereqs[os_pkg_type][os_token]["required_pkgs"]
end
repos << prereqs[os_pkg_type]["repos"]
pkgs << prereqs[os_pkg_type]["build_pkgs"]
pkgs << prereqs[os_pkg_type]["required_pkgs"]

Chef::Log.debug(repos)
Chef::Log.debug(pkgs)

repos.flatten!
repos.compact!
repos.uniq!
pkgs.flatten!
pkgs.compact!
pkgs.uniq!

Chef::Log.debug(repos)

file "/tmp/install_pkgs" do
  action :nothing
end

case node["platform"]
when "debian","ubuntu"
  template "/etc/apt/sources.list.d/crowbar.list" do
    source "crowbar.list.erb"
    variables( :repos => repos )
    notifies :create_if_missing, "file[/tmp/install_pkgs]",:immediately
  end
when "centos","redhat","suse","opensuse","fedora"
  repos.each do |repo|
    repofile_path = case node["platform"]
                    when "centos","redhat" then "/etc/yum.repos.d"
                    when "suse","opensuse" then "/etc/zypp/repos.d"
                    else raise "Don't know where to put repo files for #{node["platform"]}'"
                    end
    rtype,rdest = repo.split(" ",2)
    case rtype
    when "rpm"
      rpm_file = rdest.split("/")[-1]
      bash "Install #{rpm_file}" do
        code "rpm -Uvh /tmp/#{rpm_file}"
        action :nothing
        notifies :create_if_missing, "file[/tmp/install_pkgs]",:immediately
      end
      remote_file "/tmp/#{rpm_file}" do
        source rdest
        use_conditional_get true
        notifies :run, "bash[Install #{rpm_file}]",:immediately
      end
    when "bare"
      rname, rprio, rurl = rdest.split(" ",3)
      template "#{repofile_path}/crowbar-#{rname}.repo" do
        source "crowbar.repo.erb"
        variables(
                  :repo_name => rname,
                  :repo_prio => rprio,
                  :repo_url => rurl
                  )
        notifies :create_if_missing, "file[/tmp/install_pkgs]",:immediately
      end
    when "repo"
      rurl,rname = rdest.split(" ",2)
      template "#{repofile_path}/crowbar-#{rname}.repo" do
        source "crowbar.repo.erb"
        variables(
                  :repo_name => rname,
                  :repo_prio => 20,
                  :repo_url => rurl
                  )
        notifies :create_if_missing, "file[/tmp/install_pkgs]",:immediately
      end
    else
      raise "#{node["platform"]}: Unknown repo type #{rtype}"
    end
  end
else
  raise "Don't know how to update repositories for #{node["platform"]}"
end

bash "Install required files" do
  code case node["platform"]
       when "ubuntu","debian" then "apt-get -y update && apt-get -y --force-yes install #{pkgs.join(" ")} && rm /tmp/install_pkgs"
       when "centos","redhat","fedora" then "yum -y install #{pkgs.join(" ")} && rm /tmp/install_pkgs"
       when "suse","opensuse" then "zypper -n install #{pkgs.join(" ")} && rm /tmp/install_pkgs"
       else raise "Don't know how to install required files for #{node["platform"]}'"
       end
  only_if do ::File.exists?("/tmp/install_pkgs") end
end
pg_conf_dir = case
              when "ubuntu" then "/etc/postgresql/9.3/main"
              when "opensuse","suse" then "/var/lib/pgsql/data"
              else raise "Do not know where postgres is located for #{os_token}"
              end

service "postgresql" do
  action :start
end

# This will configure us to only listen on a local UNIX socket
template  "#{pg_conf_dir}/pg_hba.conf" do
  source "pg_hba.conf.erb"
  notifies :restart, "service[postgresql]",:immediately
end

bash "create crowbar user for postgres" do
  code "sudo -H -u postgres createuser -d -S -R -w crowbar"
  not_if "sudo -H -u postgres -- psql postgres -tAc \"SELECT 1 FROM pg_roles WHERE rolname='crowbar'\" |grep -q 1"
end

["bundler","net-http-digest_auth"].each do |g|
  gem_package g
end

