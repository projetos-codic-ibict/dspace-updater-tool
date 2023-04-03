#/bin/bash

source ./variaveis-para-atualizacao.properties

#############################
## Backups
#############################
#
##########
## Postgres
##########

docker run postgres:11 pg_dump --dbname=${POSTGRES_URL_WITHUSERNAME_AND_PASSWORD}  > ./postgres/dump.sql

docker-compose -f dockerfiles/docker-compose-postgres-only.yml up --build -d

##########
## Diretório de instalação
##########

cp -r $DSPACE_INSTALL_DIR/config dspace-install-dir
ln -s $DSPACE_INSTALL_DIR/assetstore dspace-install-dir


#########
# Backend
#########

wget https://github.com/DSpace/DSpace/archive/refs/tags/dspace-7.5.zip

unzip dspace-7.5.zip
#rm dspace-7.5.zip

mkdir -p source
mv DSpace-dspace-7.5 source

cp ./dockerfiles/Dockerfile_backend source/DSpace-dspace-7.5/Dockerfile
cp ./dockerfiles/docker-compose_migration.yml source/DSpace-dspace-7.5/

docker rm -f dspace
docker rm -f dspacesolr
docker-compose -f source/DSpace-dspace-7.5/docker-compose_migration.yml up --build -d

wget https://github.com/DSpace/dspace-angular/archive/refs/tags/dspace-7.5.zip
unzip dspace-7.5.zip
rm dspace-7.5.zip
mv dspace-angular-dspace-7.5 source
rm -rf dspace-7.5
cp ./dockerfiles/Dockerfile_frontend source/dspace-angular-dspace-7.5/Dockerfile
cp ./dockerfiles/docker-compose_frontend.yml source/dspace-angular-dspace-7.5/docker/docker-compose.yml

docker-compose -f source/dspace-angular-dspace-7.5/docker/docker-compose.yml up --build -d
