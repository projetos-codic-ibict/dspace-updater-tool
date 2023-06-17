#!/bin/bash

rm dspace-7.5.zip || true > /dev/null 2>&1 > /dev/null
sleep 1
rm -rf ./source/dspace-angular-dspace-7.5

docker rm -f dspace7-angular || true > /dev/null 2>&1 > /dev/null
docker rmi -f docker_dspace7-angular || true > /dev/null 2>&1 > /dev/null

./frontend_migra-para-dspace7.sh