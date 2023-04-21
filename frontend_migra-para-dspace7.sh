#/bin/bash

source ./variaveis-para-atualizacao.properties


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


docker run -v $(pwd)/source/dspace-angular-dspace-7.5:/root intel/qat-crypto-base:qatsw-ubuntu \
  sed -i -E "s/\/\/ Angular Universal settings/defaultLanguage: 'pt_BR',/g" /root/src/environments/environment.production.ts



cp ./dockerfiles/docker-compose_frontend.yml source/dspace-angular-dspace-7.5/docker/docker-compose.yml


echo "Setting up DSpace angular"
docker-compose -f source/dspace-angular-dspace-7.5/docker/docker-compose.yml up --build -d
