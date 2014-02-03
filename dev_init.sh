#!/bin/bash

cd rails 

echo "bundler initialize"
bundle install --verbose

echo "drop & create the database (if there was one)"
rake db:drop db:create db:migrate

echo "next step, call ./dev_mode"
