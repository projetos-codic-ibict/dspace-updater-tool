#/bin/bash

source ./variaveis-para-atualizacao.properties


docker pull intel/qat-crypto-base:qatsw-ubuntu
docker pull kubeless/unzip
docker pull alpine/git

export DSPACE_POSTGRES_PASSWORD=$(docker run intel/qat-crypto-base:qatsw-ubuntu openssl rand -base64 12)


##########
## Diretório de instalação
##########

echo "Copiando arquivos do DSpace antigo"
cp -r $DSPACE_INSTALL_DIR/config dspace-install-dir
cp -r $DSPACE_INSTALL_DIR/solr dspace-install-dir
cp -r $DSPACE_INSTALL_DIR/assetstore dspace-install-dir
cp -r $DSPACE_INSTALL_DIR/webapps dspace-install-dir


#########
# Backend
#########

echo "Efetuando download do fonte do DSpace"
if [[ "${BACKEND_ADDRESS_GIT}" ]]; then

  docker run --rm -e BACKEND_ADDRESS_GIT:${BACKEND_ADDRESS_GIT} -v $(pwd):/git -w /git alpine/git \
    && git clone --depth 1 ${BACKEND_ADDRESS_GIT} DSpace-dspace-7.5

else
  docker run --rm -v $(pwd):/unzip -w /unzip kubeless/unzip \
   && curl https://github.com/DSpace/DSpace/archive/refs/tags/dspace-7.5.zip -o dspace-7.5.zip -L \
   && unzip -q dspace-7.5.zip \
   && sleep 1 \
   && rm dspace-7.5.zip \
   && sleep 1 \
   && rm -rf dspace-7.5

fi

mkdir source || true > /dev/null 2>&1
mv DSpace-dspace-7.5 source


cp ./dockerfiles/Dockerfile_backend source/DSpace-dspace-7.5/Dockerfile
cp ./dockerfiles/docker-compose_migration.yml source/DSpace-dspace-7.5/
cp ./dockerfiles/docker-compose_restart.yml source/DSpace-dspace-7.5/

docker run --rm -v $(pwd)/source:/root -w /root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/published\: (.*) \#Port for tomcat/published\: ${BACKEND_PORT} \#Port for tomcat/g" /root/DSpace-dspace-7.5/docker-compose_migration.yml
docker run --rm -v $(pwd)/source:/root -w /root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/published\: (.*) \#Port for tomcat/published\: ${BACKEND_PORT} \#Port for tomcat/g" /root/DSpace-dspace-7.5/docker-compose_restart.yml

docker run -e DSPACE_POSTGRES_PASSWORD:${DSPACE_POSTGRES_PASSWORD} -v $(pwd)/source:/root intel/qat-crypto-base:qatsw-ubuntu sed -i -E "s/POSTGRES_PASSWORD=(.*) #Postgres password/POSTGRES_PASSWORD=${DSPACE_POSTGRES_PASSWORD} #Postgres password/g" /root/DSpace-dspace-7.5/docker-compose_migration.yml
docker run -e DSPACE_POSTGRES_PASSWORD:${DSPACE_POSTGRES_PASSWORD} -v $(pwd)/source:/root intel/qat-crypto-base:qatsw-ubuntu sed -i -E "s/POSTGRES_PASSWORD=(.*) #Postgres password/POSTGRES_PASSWORD=${DSPACE_POSTGRES_PASSWORD} #Postgres password/g" /root/DSpace-dspace-7.5/docker-compose_restart.yml

cp -r ./dockerfiles/docker/postgres ./source
cp ./dump-postgres/dump.sql ./source/postgres

docker run -e DSPACE_POSTGRES_PASSWORD:${DSPACE_POSTGRES_PASSWORD} -v $(pwd)/source:/root -w /root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/CREATE USER dspace WITH PASSWORD '(.*)'/CREATE USER dspace WITH PASSWORD '${DSPACE_POSTGRES_PASSWORD}'/g" /root/postgres/scripts/prepara-postgres.sh


echo "" > source/DSpace-dspace-7.5/dspace/config/local.cfg
cat ./local.cfg > source/DSpace-dspace-7.5/dspace/config/local.cfg
echo "db.password = ${DSPACE_POSTGRES_PASSWORD}" >> source/DSpace-dspace-7.5/dspace/config/local.cfg
echo "db.url = jdbc:postgresql://dspace7db.dspacenet:5432/dspace" >> source/DSpace-dspace-7.5/dspace/config/local.cfg
echo "dspace.server.url = ${BACKEND_PROTOCOL}://${BACKEND_HOSTNAME}:${BACKEND_PORT}/server" >> source/DSpace-dspace-7.5/dspace/config/local.cfg
echo "dspace.ui.url = ${FRONTEND_PROTOCOL}://${FRONTEND_HOSTNAME}:${FRONTEND_PORT}" >> source/DSpace-dspace-7.5/dspace/config/local.cfg

./migra-solr.sh


rm -rf ./dspace-install-dir/config/spring
cp -r ./source/DSpace-dspace-7.5/dspace/config/spring ./dspace-install-dir/config/
# Compile
mkdir ~/.m2 || true
docker run -v ~/.m2:/var/maven/.m2 -v "$(pwd)/source/DSpace-dspace-7.5":/tmp/dspacebuild -w /tmp/dspacebuild -ti --rm -e MAVEN_CONFIG=/var/maven/.m2 maven:3.8.6-openjdk-11 mvn -q --no-transfer-progress -Duser.home=/var/maven clean package -P dspace-oai,\!dspace-sword,\!dspace-swordv2,\!dspace-rdf,\!dspace-iiif
### TODO: give ant a better place

# Ant
docker run -v ~/.m2:/var/maven/.m2  -v $(pwd)/dspace-install-dir:/dspace  -v $(pwd)/source/DSpace-dspace-7.5:/tmp/dspacebuild -w /tmp/dspacebuild -ti --rm  -e MAVEN_CONFIG=/var/maven/.m2 maven:3.8.6-openjdk-11 /bin/bash -c "wget https://archive.apache.org/dist/ant/binaries/apache-ant-1.10.12-bin.tar.gz && tar -xvzf apache-ant-1.10.12-bin.tar.gz && cd dspace/target/dspace-installer && ../../../apache-ant-1.10.12/bin/ant init_installation update_configs update_code update_webapps && cd ../../../ && rm -rf apache-ant-*"


docker compose -f source/DSpace-dspace-7.5/docker-compose_migration.yml up --build -d

sleep 20


for file in ./tmp/solr_*
do
  echo "Sending file ${file##*/} to Solr..."
  docker run --rm --network="dspacenet" -e file=${file} -v $(pwd):/unzip -w /unzip kubeless/unzip curl 'http://dspace7solr:8983/solr/statistics/update?commit=true&commitWithin=1000' --data-binary @"${file}" -H 'Content-type:application/csv'
done

rm ./tmp/*
docker rm -f tomcatsolr || true
