#!/bin/bash

cd rails 

echo "bundler initialize"
bundle install --verbose

echo "create standard gem based components"
script/rails generate delayed_job:active_record
script/rails generate rails_settings:migration

echo "drop the database (if there was one)"
rake db:drop

echo "next step, call ./dev_mode"
