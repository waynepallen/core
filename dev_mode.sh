#!/bin/bash

cd rails 

bundle install --verbose
rake db:migrate

# Start crowbar services 
echo "starting the Annealer w/ 2 workers"
script/delayed_job --queue=NodeRoleRunner -n 2 start
ps axe | grep delayed_job

echo "starting the API/UI on port 3000"
rails s Puma development

#cleanup
script/delayed_job stop
echo "done"