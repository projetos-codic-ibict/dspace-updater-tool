#!/bin/bash

docker rm -f dspace7 || true > /dev/null 2>&1

./docker_compose_cmd.sh -f source/DSpace-dspace-7.6/docker-compose_restart.yml up -d
