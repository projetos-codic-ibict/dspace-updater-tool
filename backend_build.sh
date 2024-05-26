#!/bin/bash

{

  if ! [[ $1 ]]; then
    source ./upgrade-variables.properties
  else
    source ./ibict_upgrade-variables.properties
    source ./_default_instalation_variables.properties
  fi

  docker pull intel/qat-crypto-base:qatsw-ubuntu
  docker pull kubeless/unzip
  docker pull alpine/git
} >>./execution.log 2>&1

printf '
--------------------------------------
\U0001F171
--------------------------------------
\e[1mPT_BR\e[0m: Gerando uma nova senha do PostgreSQL para esta nova instalação. Você poderá encontrar a nova senha no arquivo localizado em "dspace-install-dir/config/local.cfg"
\e[1mEN\e[0m: Generating a new PostgreSQL password for this installation. You will be able to find this new password in "dspace-install-dir/config/local.cfg"
'
{
  export DSPACE_POSTGRES_PASSWORD=$(docker run --rm intel/qat-crypto-base:qatsw-ubuntu openssl rand -base64 12 | sed -e "s/\///g")
} >>./execution.log 2>&1

printf '
--------------------------------------
\U0001F172
--------------------------------------
\e[1mPT_BR\e[0m: Copiando os arquivos do diretório de instalação do DSpace
\e[1mEN\e[0m: Copying the files from the DSpace installation
'

{
  cp -r $DSPACE_INSTALL_DIR/config dspace-install-dir
  cp -r $DSPACE_INSTALL_DIR/solr dspace-install-dir
  cp -r $DSPACE_INSTALL_DIR/assetstore dspace-install-dir
  cp -r $DSPACE_INSTALL_DIR/webapps dspace-install-dir
} >>./execution.log 2>&1

if [[ "${BACKEND_ADDRESS_GIT}" ]]; then

  printf '
  --------------------------------------
  \U0001F173
  --------------------------------------
  \e[1mPT_BR\e[0m: Backend: Clonando o repositório GIT especificado como fonte para o DSpace 7.6
  \e[1mEN\e[0m: Backend: Cloning the GIT repo specified as DSpace 7.6 source
  '
  {
    docker run --rm -e BACKEND_ADDRESS_GIT:${BACKEND_ADDRESS_GIT} -v $(pwd):/git -w /git alpine/git &&
      git clone --depth 1 ${BACKEND_ADDRESS_GIT} DSpace-dspace-7.6
  } >>./execution.log 2>&1
else

  printf '
--------------------------------------
\U0001F173
--------------------------------------
\e[1mPT_BR\e[0m Backend: Efetuando o download do fonte do DSpace 7.6 do GitHub do DSpace
\e[1mEN\e[0m: Backend: Downloading the source of DSpace 7.6 from DSpace Github
'
  {
    docker run --rm -v $(pwd):/unzip -w /unzip kubeless/unzip && \
      curl https://github.com/DSpace/DSpace/archive/refs/tags/dspace-7.6.zip -o dspace-7.6.zip -L && \
      unzip -q dspace-7.6.zip && \
      sleep 1 && \
      rm dspace-7.6.zip && \
      sleep 1 && \
      rm -rf dspace-7.6
  } >>./execution.log 2>&1
fi

printf '
--------------------------------------
\U0001F174
--------------------------------------
\e[1mPT_BR\e[0m: Backend: Efetuando substituição de variáveis nos arquivos de deployment do DSpace.
\e[1mEN\e[0m: Backend: Filling the variables in the deployment files.
'

{
  mkdir source || true >/dev/null 2>&1
  mv DSpace-dspace-7.6 source

  cp ./dockerfiles/Dockerfile_backend source/DSpace-dspace-7.6/Dockerfile
  cp ./dockerfiles/docker-compose_migration.yml source/DSpace-dspace-7.6/
  cp ./dockerfiles/docker-compose_restart.yml source/DSpace-dspace-7.6/

  docker run --rm -v $(pwd)/source:/root -w /root intel/qat-crypto-base:qatsw-ubuntu \
    sed -i -E "s/published\: (.*) \#Port for tomcat/published\: ${BACKEND_PORT} \#Port for tomcat/g" /root/DSpace-dspace-7.6/docker-compose_migration.yml
  docker run --rm -v $(pwd)/source:/root -w /root intel/qat-crypto-base:qatsw-ubuntu \
    sed -i -E "s/published\: (.*) \#Port for tomcat/published\: ${BACKEND_PORT} \#Port for tomcat/g" /root/DSpace-dspace-7.6/docker-compose_restart.yml

  docker run --rm -e DSPACE_POSTGRES_PASSWORD:${DSPACE_POSTGRES_PASSWORD} -v $(pwd)/source:/root intel/qat-crypto-base:qatsw-ubuntu sed -i -E "s/POSTGRES_PASSWORD=(.*) #Postgres password/POSTGRES_PASSWORD=${DSPACE_POSTGRES_PASSWORD} #Postgres password/g" /root/DSpace-dspace-7.6/docker-compose_migration.yml
  docker run --rm -e DSPACE_POSTGRES_PASSWORD:${DSPACE_POSTGRES_PASSWORD} -v $(pwd)/source:/root intel/qat-crypto-base:qatsw-ubuntu sed -i -E "s/POSTGRES_PASSWORD=(.*) #Postgres password/POSTGRES_PASSWORD=${DSPACE_POSTGRES_PASSWORD} #Postgres password/g" /root/DSpace-dspace-7.6/docker-compose_restart.yml

  cp -r ./dockerfiles/docker/postgres ./source

  if ! [[ $1 ]]; then

    cp ./dump-postgres/dump.sql ./source/postgres

  fi

  docker run --rm -e DSPACE_POSTGRES_PASSWORD:${DSPACE_POSTGRES_PASSWORD} -v $(pwd)/source:/root -w /root intel/qat-crypto-base:qatsw-ubuntu \
    sed -i -E "s/CREATE USER dspace WITH PASSWORD '(.*)'/CREATE USER dspace WITH PASSWORD '${DSPACE_POSTGRES_PASSWORD}'/g" /root/postgres/scripts/prepara-postgres.sh

  echo "" >source/DSpace-dspace-7.6/dspace/config/local.cfg
  cat ./local.cfg >source/DSpace-dspace-7.6/dspace/config/local.cfg
  echo "db.password = ${DSPACE_POSTGRES_PASSWORD}" >>source/DSpace-dspace-7.6/dspace/config/local.cfg
  echo "db.url = jdbc:postgresql://dspace7db.dspacenet:5432/dspace" >>source/DSpace-dspace-7.6/dspace/config/local.cfg
  echo "dspace.server.url = ${BACKEND_PROTOCOL}://${BACKEND_HOSTNAME}:${BACKEND_PORT}/server" >>source/DSpace-dspace-7.6/dspace/config/local.cfg
  echo "dspace.ui.url = ${FRONTEND_PROTOCOL}://${FRONTEND_HOSTNAME}:${FRONTEND_PORT}" >>source/DSpace-dspace-7.6/dspace/config/local.cfg
} >>./execution.log 2>&1

if ! [[ $1 ]]; then
  printf '
  --------------------------------------
  \U0001F175 \t \U0001F4C8 \t \U00023F3
  --------------------------------------
  \e[1mPT_BR\e[0m: Gerando backup das estatísticas de acesso do Solr antigo. Esta operação pode demorar.
  \e[1mEN\e[0m: Generating the backup of old Solr statistics. This opperation might take a while.
  '
  source ./migrate-solr.sh
fi

printf '
--------------------------------------
\U0001F176 \t \U0001F528 \t \U00023F3
--------------------------------------
\e[1mPT_BR\e[0m: Compila o DSpace e gera o novo diretório de instalação. Esta operação pode demorar.
\e[1mEN\e[0m: Compile the DSpace source and generates the new installation directory. This opperation might take a while.
'

{
  if ! [[ $1 ]]; then
    rm -rf ./dspace-install-dir/config/spring
    cp -r ./source/DSpace-dspace-7.6/dspace/config/spring ./dspace-install-dir/config/
  fi
  # Maven
  mkdir ~/.m2 || true
  docker run -v ~/.m2:/var/maven/.m2 -v "$(pwd)/source/DSpace-dspace-7.6":/tmp/dspacebuild -w /tmp/dspacebuild -ti --rm -e MAVen_CONFIG=/var/maven/.m2 maven:3.8.6-openjdk-11 mvn -q --no-transfer-progress -Duser.home=/var/maven clean package -P dspace-oai,\!dspace-sword,\!dspace-swordv2,\!dspace-rdf,\!dspace-iiif

  # Ant
  docker run -v ~/.m2:/var/maven/.m2 -v $(pwd)/dspace-install-dir:/dspace -v $(pwd)/source/DSpace-dspace-7.6:/tmp/dspacebuild -w /tmp/dspacebuild -ti --rm -e MAVen_CONFIG=/var/maven/.m2 maven:3.8.6-openjdk-11 /bin/bash -c "wget https://archive.apache.org/dist/ant/binaries/apache-ant-1.10.12-bin.tar.gz && tar -xvzf apache-ant-1.10.12-bin.tar.gz && cd dspace/target/dspace-installer && ../../../apache-ant-1.10.12/bin/ant init_installation update_configs update_code update_webapps && cd ../../../ && rm -rf apache-ant-*"
} >>./execution.log 2>&1

printf '
--------------------------------------
\U0001F177
--------------------------------------
\e[1mPT_BR\e[0m: Inicializa o DSpace server
\e[1mEN\e[0m: Initializes the DSpace sever
'

{
  if ! [[ $1 ]]; then
    docker compose -f source/DSpace-dspace-7.6/docker-compose_migration.yml up --build -d
  else
    docker compose -f source/DSpace-dspace-7.6/docker-compose_restart.yml up --build -d
  fi

  sleep 10
} >>./execution.log 2>&1


if ! [[ $1 ]]; then

  printf '
  --------------------------------------
  \U0001F178 \t \U0001F4C8 \t \U00023F3
  --------------------------------------
  \e[1mPT_BR\e[0m: Importa o backup do Solr gerado anteriormente para a nova instância do Solr. Esta operação pode demorar.
  \e[1mEN\e[0m: Imports the previous generated Solr dump to the new instance of Solr. This opperation might take a while.
  '

  {
    for file in ./tmp/solr_*; do
      echo "Sending file ${file##*/} to Solr..."
      docker run --rm --network="dspacenet" -e file=${file} -v $(pwd):/unzip -w /unzip kubeless/unzip curl 'http://dspace7solr:8983/solr/statistics/update?commit=true&commitWithin=1000' --data-binary @"${file}" -H 'Content-type:application/csv'
    done

    sudo rm -rf ./tmp/*
    docker rm -f tomcatsolr || true
  } >>./execution.log 2>&1

fi
printf '
--------------------------------------
\U0001F179 \t \U0001F680 \U0001F389
--------------------------------------
\e[1mPT_BR\e[0m: O backend do DSpace está pronto! Os endereços do DSpace deverão estar disponíveis nos endereços informados no arquivo de variáveis.
\e[1mEN\e[0m: The DSpace backend is ready! The access URLs will be the ones registered in the variables files.
'
