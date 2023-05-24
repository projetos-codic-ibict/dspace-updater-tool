#/bin/bash

echo "Informe o usuário root para remover o diretório de instalação do DSpace 7 (um novo será recriado)"
sudo rm -rf ./dspace-install-dir/*

echo "Removendo containers antigos"
rm -rf ./source/DSpace-dspace-7.5
rm dspace-7.5.zip || true > /dev/null 2>&1

docker rm -f dspace7 || true > /dev/null 2>&1
docker rmi -f dspace-dspace-75-dspace7 || true > /dev/null 2>&1

docker rm -f dspace7db || true > /dev/null 2>&1
docker rm -f dspace7solr || true > /dev/null 2>&1
docker rmi -f ibict/postgresdspace7 || true > /dev/null 2>&1

./backend_migra-para-dspace7.sh