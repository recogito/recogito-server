#!/usr/bin/env bash

set -o allexport
source .env set
set +o allexport

supabase db reset

sleep 5

node ./create-default-groups.js -f ./config.json

sleep 2

node ./create-test-users.js -f ./config.json

sleep 2

yarn --cwd ./jest run test
