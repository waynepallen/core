#!/bin/bash

cd rails 

echo "bundler initialize"
bundle install --verbose

echo "drop & create the database (if there was one)"
rake db:drop db:create db:migrate

echo "create standard gem based components"
script/rails generate delayed_job:active_record
script/rails generate rails_settings:migration
rake db:migrate

echo "next step, call ./dev_mode"
