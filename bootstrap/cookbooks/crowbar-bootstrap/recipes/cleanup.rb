[
 "/root/.ssh",
 "/home/crowbar/.ssh",
 "/var/cache/crowbar/rails-cache",
 "/var/log/crowbar",
 "/var/cache/yum",
 "/var/cache/apt/archives",
].each do |target|
  directory target do
    action :delete
    recursive true
  end
end

service "postgresql" do
  action :stop
end
