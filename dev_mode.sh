#!/bin/bash

cd rails 

bundle install --verbose
rake db:migrate

# Start crowbar services 
script/delayed_job --queue=NodeRoleRunner -n 2 start
rails s Puma development

#cleanup
script/delayed_job stop