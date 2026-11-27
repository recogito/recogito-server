#!/usr/bin/env bash

set -o allexport
source .env
set +o allexport

supabase db reset

sleep 5

node ./create-default-groups.js -f ./config.json

sleep 2

node ./create-test-users.js
