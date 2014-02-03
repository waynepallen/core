#!/bin/bash

cd rails
bundle exec rake db:drop \
    db:create \
    railties:install:migrations \
    db:migrate

# Start crowbar services 
echo "starting the Annealer w/ 2 workers"
bundle exec script/delayed_job --queue=NodeRoleRunner -n 2 start
ps axe | grep delayed_job

echo "starting the API/UI on port 3000"
bundle exec script/rails s Puma development

#cleanup
bundle exec script/delayed_job stop
echo "done"
