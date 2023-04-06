#/bin/bash

source ./variaveis-para-atualizacao.properties

echo "Antes de iniciar edite as variáveis abaixo no arquivo migracao-dspace/dockerfiles/docker-compose_migration.yml:
      	dspace__P__server__P__url
      	dspace__P__ui__P__url
      	dspace__P__name

      No arquivo migracao-dspace/dockerfiles/docker-compose_frontend.yml, edite as variáveis:
      	DSPACE_UI_SSL
      	DSPACE_UI_HOST
      	DSPACE_UI_PORT
      	DSPACE_UI_NAMESPACE
      	DSPACE_REST_SSL
      	DSPACE_REST_HOST
      	DSPACE_REST_PORT
      	DSPACE_REST_NAMESPACE

      No arquivo variaveis-para-atualizacao.properties, edite todas variáveis "

read -p "Todos os arquivos estão devidamente editados?" -n 1 -r
echo    
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi



#############################
## Backups
#############################
#
##########
## Postgres
##########

echo "Generating DSpace dump"

docker run postgres:12 pg_dump --dbname=${POSTGRES_URL_WITHUSERNAME_AND_PASSWORD}  > ./dockerfiles/docker/postgres/dump.sql

##
read -p "O último comando ocorreu com sucesso? " -n 1 -r
echo    
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

docker-compose -f dockerfiles/docker-compose-postgres-only.yml up --build -d

#
read -p "O último comando ocorreu com sucesso? " -n 1 -r
echo    
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

##########
## Diretório de instalação
##########

echo "Copying DSpace DIR files (config and assetstore)"
cp -r $DSPACE_INSTALL_DIR/config dspace-install-dir
ln -s $DSPACE_INSTALL_DIR/assetstore dspace-install-dir

#
read -p "O último comando ocorreu com sucesso? " -n 1 -r
echo    
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

#########
# Backend
#########

echo "Downloading DSpace versions"
#wget https://github.com/DSpace/DSpace/archive/refs/tags/dspace-7.5.zip

unzip dspace-7.5.zip
rm dspace-7.5.zip
mv DSpace-dspace-7.5 source

cp ./dockerfiles/Dockerfile_backend source/DSpace-dspace-7.5/Dockerfile
cp ./dockerfiles/docker-compose_migration.yml source/DSpace-dspace-7.5/

docker rm -f dspace
docker rm -f dspacesolr

echo "Setting up DSpace backend"

docker-compose -f source/DSpace-dspace-7.5/docker-compose_migration.yml up --build -d


read -p "O último comando ocorreu com sucesso? " -n 1 -r
echo    
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

wget https://github.com/DSpace/dspace-angular/archive/refs/tags/dspace-7.5.zip
unzip dspace-7.5.zip
rm dspace-7.5.zip
mv dspace-angular-dspace-7.5 source
rm -rf dspace-7.5
cp ./dockerfiles/Dockerfile_frontend source/dspace-angular-dspace-7.5/Dockerfile
cp ./dockerfiles/docker-compose_frontend.yml source/dspace-angular-dspace-7.5/docker/docker-compose.yml

#
read -p "O último comando ocorreu com sucesso? " -n 1 -r
echo    
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

echo "Setting up DSpace angular"
docker-compose -f source/dspace-angular-dspace-7.5/docker/docker-compose.yml up --build -d
