# Load the rails application
require File.expand_path('../application', __FILE__)

if File.exists?("/opt/opencrowbar/core/chef/cookbooks/barclamp/libraries")
  require "/opt/opencrowbar/core/chef/cookbooks/barclamp/libraries/ip.rb"
  require "/opt/opencrowbar/core/chef/cookbooks/barclamp/libraries/nic.rb"
  require "/opt/opencrowbar/core/chef/cookbooks/barclamp/libraries/nethelper.rb"
end

# Initialize the rails application
Crowbar::Application.initialize!
