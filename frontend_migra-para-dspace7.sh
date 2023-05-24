#/bin/bash

source ./variaveis-para-atualizacao.properties

docker pull intel/qat-crypto-base:qatsw-ubuntu
docker pull kubeless/unzip


if [[ "${FRONTEND_ADDRESS_GIT}" ]]; then

  docker run --rm -e FRONTEND_ADDRESS_GIT:${FRONTEND_ADDRESS_GIT} -v $(pwd):/git -w /git alpine/git \
    && git clone --depth 1 ${FRONTEND_ADDRESS_GIT} dspace-angular-dspace-7.5

else
  docker run --rm -v $(pwd):/unzip -w /unzip kubeless/unzip \
   && curl https://github.com/DSpace/dspace-angular/archive/refs/tags/dspace-7.5.zip -o dspace-7.5.zip -L \
   && unzip -q dspace-7.5.zip \
   && rm dspace-7.5.zip \
   && rm -rf dspace-7.5

fi

mkdir source || true
mv dspace-angular-dspace-7.5 source
cp ./dockerfiles/Dockerfile_frontend source/dspace-angular-dspace-7.5/Dockerfile
cp ./dockerfiles/docker-compose_frontend.yml source/dspace-angular-dspace-7.5/docker/docker-compose.yml

sleep 1
docker run --rm -v $(pwd)/source/dspace-angular-dspace-7.5/docker:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/DSPACE_UI_SSL: '(.*)'/DSPACE_UI_SSL: '${FRONTEND_USES_SSL}'/g" /root/docker-compose.yml

sleep 1
docker run --rm -v $(pwd)/source/dspace-angular-dspace-7.5/docker:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/DSPACE_UI_HOST: '(.*)'/DSPACE_UI_HOST: '${FRONTEND_HOSTNAME}'/g" /root/docker-compose.yml

sleep 1
docker run --rm -v $(pwd)/source/dspace-angular-dspace-7.5/docker:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/DSPACE_UI_PORT: '(.*)'/DSPACE_UI_PORT: '${FRONTEND_PORT}'/g" /root/docker-compose.yml

sleep 1
docker run --rm -v $(pwd)/source/dspace-angular-dspace-7.5/docker:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/published: (.*)/published: ${FRONTEND_PORT}/g" /root/docker-compose.yml

sleep 1
docker run --rm -v $(pwd)/source/dspace-angular-dspace-7.5/docker:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/target: (.*)/target: ${FRONTEND_PORT}/g" /root/docker-compose.yml

sleep 1
docker run --rm -v $(pwd)/source/dspace-angular-dspace-7.5/docker:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/DSPACE_REST_SSL: '(.*)'/DSPACE_REST_SSL: '${BACKEND_USES_SSL}'/g" /root/docker-compose.yml

sleep 1
docker run --rm -v $(pwd)/source/dspace-angular-dspace-7.5/docker:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/DSPACE_REST_HOST: '(.*)'/DSPACE_REST_HOST: '${BACKEND_HOSTNAME}'/g" /root/docker-compose.yml

sleep 1
docker run --rm -v $(pwd)/source/dspace-angular-dspace-7.5/docker:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/DSPACE_REST_PORT: '(.*)'/DSPACE_REST_PORT: '${BACKEND_PORT}'/g" /root/docker-compose.yml

sleep 1
docker run --rm -v $(pwd)/source/dspace-angular-dspace-7.5:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/\/\/ Angular Universal settings/defaultLanguage: 'pt_BR',/g" /root/src/environments/environment.ts

sleep 1
docker run --rm -v $(pwd)/source/dspace-angular-dspace-7.5:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/production\: false/production\: true/g" /root/src/environments/environment.ts





echo "Setting up DSpace angular"
docker compose -f source/dspace-angular-dspace-7.5/docker/docker-compose.yml up --build -d
