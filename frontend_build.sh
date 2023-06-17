#!/bin/bash

printf '
--------------------------------------
\U0001F181
--------------------------------------
\e[1mPT_BR\e[0m: Frontend: Removendo arquivos e container de execuções antigas (caso eles existam).
Sua senha root será solicitada.

\e[1mEN\e[0m: Frontend: Deleting old files and containers from previous executions (in case they exists).
Your root password will be requested.
'
{
  source ./upgrade-variables.properties

  docker pull intel/qat-crypto-base:qatsw-ubuntu
  docker pull kubeless/unzip
} >>./execution.log 2>&1

{
if [[ "${FRONTEND_ADDRESS_GIT}" ]]; then
printf '
--------------------------------------
\U0001F182
--------------------------------------
\e[1mPT_BR\e[0m: Frontend: Clonando o repositório GIT especificado como fonte para o DSpace 7.5
\e[1mEN\e[0m: Frontend: Cloning the GIT repo specified as DSpace 7.5 source
'

  docker run --rm -e FRONTEND_ADDRESS_GIT:${FRONTEND_ADDRESS_GIT} -v $(pwd):/git -w /git alpine/git &&
    git clone --depth 1 ${FRONTEND_ADDRESS_GIT} dspace-angular-dspace-7.5

else
printf '
--------------------------------------
\U0001F183
--------------------------------------
\e[1mPT_BR\e[0m Backend: Efetuando o download do fonte do DSpace 7.5 do GitHub do DSpace
\e[1mEN\e[0m: Backend: Downloading the source of DSpace 7.5 from DSpace Github
'
  docker run --rm -v $(pwd):/unzip -w /unzip kubeless/unzip &&
    curl https://github.com/DSpace/dspace-angular/archive/refs/tags/dspace-7.5.zip -o dspace-7.5.zip -L &&
    unzip -q dspace-7.5.zip &&
    rm dspace-7.5.zip &&
    rm -rf dspace-7.5
fi
} >>./execution.log 2>&1

printf '
--------------------------------------
\U0001F184
--------------------------------------
\e[1mPT_BR\e[0m: Backend: Efetuando substituição de variáveis nos arquivos de deployment do DSpace.
\e[1mEN\e[0m: Backend: Filling the variables in the deployment files.
'

{
  mkdir source || true >/dev/null 2>&1
  mv dspace-angular-dspace-7.5 source
  cp ./dockerfiles/Dockerfile_frontend source/dspace-angular-dspace-7.5/Dockerfile
  cp ./dockerfiles/docker-compose_frontend.yml source/dspace-angular-dspace-7.5/docker/docker-compose.yml

docker run --rm -v $(pwd)/source/dspace-angular-dspace-7.5/docker:/root -w /root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/DSPACE_UI_SSL: '(.*)'/DSPACE_UI_SSL: '${FRONTEND_USES_SSL}'/g" /root/docker-compose.yml


docker run --rm -v $(pwd)/source/dspace-angular-dspace-7.5/docker:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/DSPACE_UI_HOST: '(.*)'/DSPACE_UI_HOST: '${FRONTEND_HOSTNAME}'/g" /root/docker-compose.yml


docker run --rm -v $(pwd)/source/dspace-angular-dspace-7.5/docker:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/DSPACE_UI_PORT: '(.*)'/DSPACE_UI_PORT: '${FRONTEND_PORT}'/g" /root/docker-compose.yml


docker run --rm -v $(pwd)/source/dspace-angular-dspace-7.5/docker:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/published: (.*)/published: ${FRONTEND_PORT}/g" /root/docker-compose.yml


docker run --rm -v $(pwd)/source/dspace-angular-dspace-7.5/docker:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/target: (.*)/target: ${FRONTEND_PORT}/g" /root/docker-compose.yml


docker run --rm -v $(pwd)/source/dspace-angular-dspace-7.5/docker:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/DSPACE_REST_SSL: '(.*)'/DSPACE_REST_SSL: '${BACKEND_USES_SSL}'/g" /root/docker-compose.yml


docker run --rm -v $(pwd)/source/dspace-angular-dspace-7.5/docker:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/DSPACE_REST_HOST: '(.*)'/DSPACE_REST_HOST: '${BACKEND_HOSTNAME}'/g" /root/docker-compose.yml


docker run --rm -v $(pwd)/source/dspace-angular-dspace-7.5/docker:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/DSPACE_REST_PORT: '(.*)'/DSPACE_REST_PORT: '${BACKEND_PORT}'/g" /root/docker-compose.yml


docker run --rm -v $(pwd)/source/dspace-angular-dspace-7.5:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/\/\/ Angular Universal settings/defaultLanguage: 'pt_BR',/g" /root/src/environments/environment.ts


docker run --rm -v $(pwd)/source/dspace-angular-dspace-7.5:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/production\: false/production\: true/g" /root/src/environments/environment.ts

} >>./execution.log 2>&1

printf '
--------------------------------------
\U0001F185 \t \U00023F3
--------------------------------------
\e[1mPT_BR\e[0m: Inicializa o DSpace frontend
\e[1mEN\e[0m: Initializes the DSpace frontend
'

{
  echo "Setting up DSpace angular"
  docker compose -f source/dspace-angular-dspace-7.5/docker/docker-compose.yml up --build -d
} >>./execution.log 2>&1
