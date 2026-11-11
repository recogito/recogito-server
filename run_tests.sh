#!/usr/bin/env bash

set -o allexport
source .env
set +o allexport

./reset.sh

sleep 2

npm --prefix ./jest run test
