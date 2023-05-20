#/bin/bash

docker rm -f dspace-angular
docker rmi -f docker_dspace-angular

docker compose -f source/dspace-angular-dspace-7.5/docker/docker-compose.yml up --build -d