#/bin/bash

rm -rf ./tmp/*

sudo rm -rf ./dspace-install-dir/*

echo "Removendo containers antigos"
rm -rf ./source/DSpace-dspace-7.5
rm dspace-7.5.zip || true > /dev/null 2>&1

docker rm -f dspace7 || true > /dev/null 2>&1
docker rmi -f dspace-dspace-75-dspace7 || true > /dev/null 2>&1

docker rm -f dspace7db || true > /dev/null 2>&1
docker rm -f dspace7solr || true > /dev/null 2>&1
docker rmi -f ibict/postgresdspace7 || true > /dev/null 2>&1

docker volume rm dspace-dspace-75_solr_data || true > /dev/null 2>&1

./backend_migra-para-dspace7.sh