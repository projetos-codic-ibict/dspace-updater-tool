#/bin/bash

echo "Este procedimento irá re-utilizar o dump do postgres\n"

echo "Informe o usuário root para remover o diretório de instalação do DSpace 7 (um novo será recriado)"
sudo rm -rf ./dspace-install-dir/*
rm -rf ./source/*

docker rm -f dspace
docker rmi -f dspace-dspace-75_dspace

docker rm -f bd_dspace7
docker rmi -f ibict/postgresdspace7

docker rm -f dspace-angular
docker rmi -f docker_dspace-angular

./atualiza-dspace.sh