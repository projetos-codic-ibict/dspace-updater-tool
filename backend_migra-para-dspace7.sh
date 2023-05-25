#/bin/bash

source ./variaveis-para-atualizacao.properties

# Este procedimento leva em torno de 30 minutos, o tempo pode veriar de acordo com o hardware utilizado
# Certifique de que o seu servidor tenha ao menos o dobro de disco rígido disponível, quando comparado ao espaço utilizado
# Certifique que seu servidor tenha ao menos 8GB de RAM
# Editar arquivos não solicitados pode acarretar na falha de execução deste programa

# Vantagens
# Não exige que seu servidor tenha java (ou java atualizado), ant, maven
# Não é instrusivo, toods recursos do seu dspace antigo serão copiados, com única exceção do diretório "assetstore"

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


mkdir -p ./dspace-install-dir/solr-conversion-files/libs
export URL_BASE=https://repo1.maven.org/maven2/org/apache/lucene
export DEST_FOLDER=./dspace-install-dir/solr-conversion-files/libs

docker run --rm -e $URL_BASE:URL_BASE -e $DEST_FOLDER:DEST_FOLDER -v $(pwd):/unzip -w /unzip kubeless/unzip \
 && curl $URL_BASE/lucene-core/4.10.4/lucene-core-4.10.4.jar -o $DEST_FOLDER/lucene-core-4.jar -L \
 && curl $URL_BASE/lucene-backward-codecs/4.10.4/lucene-backward-codecs-4.10.4.jar -o $DEST_FOLDER/back-lucene-core-4.jar -L \
 && curl $URL_BASE/lucene-core/5.5.4/lucene-core-5.5.4.jar -o $DEST_FOLDER/lucene-core-5.jar -L \
 && curl $URL_BASE/lucene-backward-codecs/5.5.4/lucene-backward-codecs-5.5.4.jar -o $DEST_FOLDER/back-lucene-core-5.jar -L \
 && curl $URL_BASE/lucene-core/6.6.0/lucene-core-6.6.0.jar -o $DEST_FOLDER/lucene-core-6.jar -L \
 && curl $URL_BASE/lucene-backward-codecs/6.6.0/lucene-backward-codecs-6.6.0.jar -o $DEST_FOLDER/back-lucene-core-6.jar -L \
 && curl $URL_BASE/lucene-core/7.7.0/lucene-core-7.7.0.jar -o $DEST_FOLDER/lucene-core-7.jar -L \
 && curl $URL_BASE/lucene-backward-codecs/7.7.0/lucene-backward-codecs-7.7.0.jar -o $DEST_FOLDER/back-lucene-core-7.jar -L \
 && curl $URL_BASE/lucene-core/8.11.1/lucene-core-8.11.1.jar -o $DEST_FOLDER/lucene-core-8.jar -L \
 && curl $URL_BASE/lucene-backward-codecs/8.11.1/lucene-backward-codecs-8.11.1.jar -o $DEST_FOLDER/back-lucene-core-8.jar -L


for version in 4 5 6 7 8
do
   echo "Atualizando indices Solr para versão ${version}... (aguarde)"
   docker run --rm -e $version:version -v $(pwd):/install-dir -w /install-dir adoptopenjdk/openjdk11 \
     echo "* " \
     && java -cp ./dspace-install-dir/solr-conversion-files/libs/lucene-core-${version}.jar:./dspace-install-dir/solr-conversion-files/libs/back-lucene-core-${version}.jar org.apache.lucene.index.IndexUpgrader -delete-prior-commits ./dspace-install-dir/solr/authority/data/index \
     && java -cp ./dspace-install-dir/solr-conversion-files/libs/lucene-core-${version}.jar:./dspace-install-dir/solr-conversion-files/libs/back-lucene-core-${version}.jar org.apache.lucene.index.IndexUpgrader -delete-prior-commits ./dspace-install-dir/solr/oai/data/index \
     && java -cp ./dspace-install-dir/solr-conversion-files/libs/lucene-core-${version}.jar:./dspace-install-dir/solr-conversion-files/libs/back-lucene-core-${version}.jar org.apache.lucene.index.IndexUpgrader -delete-prior-commits ./dspace-install-dir/solr/search/data/index \
     && java -cp ./dspace-install-dir/solr-conversion-files/libs/lucene-core-${version}.jar:./dspace-install-dir/solr-conversion-files/libs/back-lucene-core-${version}.jar org.apache.lucene.index.IndexUpgrader -delete-prior-commits ./dspace-install-dir/solr/statistics/data/index
done

docker compose -f source/DSpace-dspace-7.5/docker-compose_migration.yml up --build -d

sleep 10

docker exec -it dspace7 /dspace/bin/dspace filter-media &

