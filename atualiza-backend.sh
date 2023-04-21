#/bin/bash

docker rm -f dspace
docker rmi -f dspace-dspace-75_dspace

docker-compose -f source/DSpace-dspace-7.5/docker-compose.yml up --build -d
