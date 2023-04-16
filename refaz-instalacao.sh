#/bin/bash

echo "Este procedimento irá re-utilizar o dump do postgres\n"

echo "Informe o usuário root para remover o diretório de instalação do DSpace 7 (um novo será recriado)"
sudo rm -rf ./dspace-install-dir/*
rm -rf ./source/*

./atualiza-dspace.sh