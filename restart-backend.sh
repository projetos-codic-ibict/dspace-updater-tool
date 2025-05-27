#!/bin/bash

docker rm -f dspace7 || true > /dev/null 2>&1

docker compose -f source/DSpace-dspace-8.1/docker-compose_restart.yml up -d
