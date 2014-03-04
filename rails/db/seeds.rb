# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
source_path = File.expand_path(File.join(__FILE__,"../../.."))
yml_blob = YAML.load_file(File.join(source_path,"crowbar.yml"))
Barclamp.import("core",yml_blob,source_path)
Dir.glob("/opt/opencrowbar/**/crowbar_engine/barclamp_*/db/seeds.rb") do |seedfile|
  "#{seedfile.split('/')[-3].camelize}::Engine".constantize.load_seed
end
