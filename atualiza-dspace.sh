#/bin/bash

source ./variaveis-para-atualizacao.properties

# Este procedimento leva em torno de 30 minutos, o tempo pode veriar de acordo com o hardware utilizado
# Certifique de que o seu servidor tenha ao menos o dobro de disco rígido disponível, quando comparado ao espaço utilizado
# Certifique que seu servidor tenha ao menos 8GB de RAM
# Editar arquivos não solicitados pode acarretar na falha de execução deste programa

# Vantagens
# Não exige que seu servidor tenha java (ou java atualizado), ant, maven
# Não é instrusivo, toods recursos do seu dspace antigo serão copiados, com única exceção do diretório "assetstore"

# Senha do postgres
docker pull intel/qat-crypto-base:qatsw-ubuntu

export DSPACE_POSTGRES_PASSWORD=$(docker run intel/qat-crypto-base:qatsw-ubuntu openssl rand -base64 12)

##########
## Diretório de instalação
##########

echo "Copying DSpace DIR files (config and assetstore)"
cp -r $DSPACE_INSTALL_DIR/config dspace-install-dir
cp -r $DSPACE_INSTALL_DIR/solr dspace-install-dir
ln -s $DSPACE_INSTALL_DIR/assetstore dspace-install-dir

#########
# Backend
#########

echo "Downloading DSpace versions"
wget https://github.com/DSpace/DSpace/archive/refs/tags/dspace-7.5.zip

unzip dspace-7.5.zip
rm dspace-7.5.zip
mv DSpace-dspace-7.5 source

cp ./dockerfiles/Dockerfile_backend source/DSpace-dspace-7.5/Dockerfile
cp ./dockerfiles/docker-compose_migration.yml source/DSpace-dspace-7.5/

docker run -v $(pwd)/source:/root intel/qat-crypto-base:qatsw-ubuntu sed -i -E "s/published\: (.*) \#Port for tomcat/published\: ${BACKEND_PORT} \#Port for tomcat/g" /root/DSpace-dspace-7.5/docker-compose_migration.yml
docker run -e DSPACE_POSTGRES_PASSWORD:${DSPACE_POSTGRES_PASSWORD} -v $(pwd)/source:/root intel/qat-crypto-base:qatsw-ubuntu sed -i -E "s/POSTGRES_PASSWORD=(.*) #Postgres password/POSTGRES_PASSWORD=${DSPACE_POSTGRES_PASSWORD} #Postgres password/g" /root/DSpace-dspace-7.5/docker-compose_migration.yml

cp -r ./dockerfiles/docker/postgres ./source
cp ./dump-postgres/dump.sql ./source/postgres
docker run -e DSPACE_POSTGRES_PASSWORD:${DSPACE_POSTGRES_PASSWORD} -v $(pwd)/source:/root intel/qat-crypto-base:qatsw-ubuntu  sed -i -E "s/CREATE USER dspace WITH PASSWORD '(.*)'/CREATE USER dspace WITH PASSWORD '${DSPACE_POSTGRES_PASSWORD}'/g" /root/postgres/scripts/prepara-postgres.sh

docker rm -f dspace
docker rm -f dspacesolr

echo "" > source/DSpace-dspace-7.5/dspace/config/local.cfg
cat ./local.cfg > source/DSpace-dspace-7.5/dspace/config/local.cfg
echo "db.password = ${DSPACE_POSTGRES_PASSWORD}" >> source/DSpace-dspace-7.5/dspace/config/local.cfg
echo "db.url = jdbc:postgresql://bd_dspace7:5432/dspace" >> source/DSpace-dspace-7.5/dspace/config/local.cfg
echo "dspace.server.url = ${BACKEND_PROTOCOL}://${BACKEND_HOSTNAME}:${BACKEND_PORT}/server" >> source/DSpace-dspace-7.5/dspace/config/local.cfg
echo "dspace.ui.url = ${FRONTEND_PROTOCOL}://${FRONTEND_HOSTNAME}:${FRONTEND_PORT}" >> source/DSpace-dspace-7.5/dspace/config/local.cfg

echo "Setting up DSpace backend"


docker-compose -f source/DSpace-dspace-7.5/docker-compose_migration.yml up --build -d


wget https://github.com/DSpace/dspace-angular/archive/refs/tags/dspace-7.5.zip
unzip dspace-7.5.zip
rm dspace-7.5.zip
mv dspace-angular-dspace-7.5 source
rm -rf dspace-7.5
cp ./dockerfiles/Dockerfile_frontend source/dspace-angular-dspace-7.5/Dockerfile


docker run -v $(pwd)/dockerfiles:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/DSPACE_UI_SSL: '(.*)'/DSPACE_UI_SSL: '${FRONTEND_USES_SSL}'/g" /root/docker-compose_frontend.yml

docker run -v $(pwd)/dockerfiles:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/DSPACE_UI_HOST: '(.*)'/DSPACE_UI_HOST: '${FRONTEND_HOSTNAME}'/g" /root/docker-compose_frontend.yml

docker run -v $(pwd)/dockerfiles:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/DSPACE_UI_PORT: '(.*)'/DSPACE_UI_PORT: '${FRONTEND_PORT}'/g" /root/docker-compose_frontend.yml

docker run -v $(pwd)/dockerfiles:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/DSPACE_REST_SSL: '(.*)'/DSPACE_REST_SSL: '${BACKEND_USES_SSL}'/g" /root/docker-compose_frontend.yml

docker run -v $(pwd)/dockerfiles:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/DSPACE_REST_HOST: '(.*)'/DSPACE_REST_HOST: '${BACKEND_HOSTNAME}'/g" /root/docker-compose_frontend.yml

docker run -v $(pwd)/dockerfiles:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/DSPACE_REST_PORT: '(.*)'/DSPACE_REST_PORT: '${BACKEND_PORT}'/g" /root/docker-compose_frontend.yml


cp ./dockerfiles/docker-compose_frontend.yml source/dspace-angular-dspace-7.5/docker/docker-compose.yml


echo "Setting up DSpace angular"
docker-compose -f source/dspace-angular-dspace-7.5/docker/docker-compose.yml up --build -d
