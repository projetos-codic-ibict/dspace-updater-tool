#/bin/bash

source ./variaveis-para-atualizacao.properties

docker pull intel/qat-crypto-base:qatsw-ubuntu
docker pull kubeless/unzip


docker run --rm -v $(pwd):/unzip -w /unzip kubeless/unzip \
 && curl https://github.com/DSpace/dspace-angular/archive/refs/tags/dspace-7.5.zip -o dspace-7.5.zip -L \
 && unzip dspace-7.5.zip \
 && rm dspace-7.5.zip \
 && rm -rf dspace-7.5

mv dspace-angular-dspace-7.5 source
cp ./dockerfiles/Dockerfile_frontend source/dspace-angular-dspace-7.5/Dockerfile


docker run --rm -v $(pwd)/dockerfiles:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/DSPACE_UI_SSL: '(.*)'/DSPACE_UI_SSL: '${FRONTEND_USES_SSL}'/g" /root/docker-compose_frontend.yml

docker run --rm -v $(pwd)/dockerfiles:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/DSPACE_UI_HOST: '(.*)'/DSPACE_UI_HOST: '${FRONTEND_HOSTNAME}'/g" /root/docker-compose_frontend.yml

docker run --rm -v $(pwd)/dockerfiles:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/DSPACE_UI_PORT: '(.*)'/DSPACE_UI_PORT: '${FRONTEND_PORT}'/g" /root/docker-compose_frontend.yml

docker run --rm -v $(pwd)/dockerfiles:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/DSPACE_REST_SSL: '(.*)'/DSPACE_REST_SSL: '${BACKEND_USES_SSL}'/g" /root/docker-compose_frontend.yml

docker run --rm -v $(pwd)/dockerfiles:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/DSPACE_REST_HOST: '(.*)'/DSPACE_REST_HOST: '${BACKEND_HOSTNAME}'/g" /root/docker-compose_frontend.yml

docker run --rm -v $(pwd)/dockerfiles:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/DSPACE_REST_PORT: '(.*)'/DSPACE_REST_PORT: '${BACKEND_PORT}'/g" /root/docker-compose_frontend.yml


docker run --rm -v $(pwd)/source/dspace-angular-dspace-7.5:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/\/\/ Angular Universal settings/defaultLanguage: 'pt_BR',/g" /root/src/environments/environment.ts



cp ./dockerfiles/docker-compose_frontend.yml source/dspace-angular-dspace-7.5/docker/docker-compose.yml


echo "Setting up DSpace angular"
docker-compose -f source/dspace-angular-dspace-7.5/docker/docker-compose.yml up --build -d
