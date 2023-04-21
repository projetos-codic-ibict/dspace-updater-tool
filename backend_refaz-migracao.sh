#/bin/bash

echo "Este procedimento irá re-utilizar o dump do postgres\n"

echo "Informe o usuário root para remover o diretório de instalação do DSpace 7 (um novo será recriado)"
sudo rm -rf ./dspace-install-dir/*
rm -rf ./source/DSpace-dspace-7.5
rm dspace-7.5.zip || true


docker rm -f dspace || true
docker rmi -f dspace-dspace-75_dspace || true

docker rm -f bd_dspace7 || true
docker rmi -f ibict/postgresdspace7 || true

./backend_migra-para-dspace7.sh