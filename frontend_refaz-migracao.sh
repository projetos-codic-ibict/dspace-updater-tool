#/bin/bash

rm dspace-7.5.zip || true
sleep 1
rm -rf ./source/dspace-angular-dspace-7.5

docker rm -f dspace-angular || true
docker rmi -f docker_dspace-angular || true

./frontend_migra-para-dspace7.sh