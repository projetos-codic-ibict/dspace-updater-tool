#/bin/bash

docker rm -f dspace7-angular
docker rmi -f docker_dspace7-angular

docker compose -f source/dspace-angular-dspace-7.5/docker/docker-compose.yml up --build -d