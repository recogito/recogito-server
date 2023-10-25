#!/usr/bin/env bash

set -o allexport
source .env set
set +o allexport

supabase db reset

node ./create-default-groups.js -f ./config.json
node ./create-test-users.js -f ./config.json

yarn --cwd ./jest run test
