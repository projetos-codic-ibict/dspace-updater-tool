#!/bin/bash

echo "Copiand config/spring..."
rm -rf dspace-install-dir/config/spring
cp -r source/DSpace-dspace-7.6/dspace/config/spring ./dspace-install-dir/config/

# Maven
echo "Executando maven..."
docker run -v ~/.m2:/var/maven/.m2 -v "$(pwd)/source/DSpace-dspace-7.6":/tmp/dspacebuild -w /tmp/dspacebuild --rm -e MAVen_CONFIG=/var/maven/.m2 maven:3.8.6-openjdk-11 mvn -q --no-transfer-progress -Duser.home=/var/maven clean package -P dspace-oai,\!dspace-sword,\!dspace-swordv2,\!dspace-rdf,\!dspace-iiif

# Ant
echo "Executando ant..."
docker run -v ~/.m2:/var/maven/.m2 -v $(pwd)/dspace-install-dir:/dspace -v $(pwd)/source/DSpace-dspace-7.6:/tmp/dspacebuild -w /tmp/dspacebuild --rm -e MAVen_CONFIG=/var/maven/.m2 maven:3.8.6-openjdk-11 /bin/bash -c "wget https://archive.apache.org/dist/ant/binaries/apache-ant-1.10.12-bin.tar.gz && tar -xvzf apache-ant-1.10.12-bin.tar.gz && cd dspace/target/dspace-installer && ../../../apache-ant-1.10.12/bin/ant init_installation update_configs update_code update_webapps && cd ../../../ && rm -rf apache-ant-*"

echo "Removendo container dspace7"
docker rm -f dspace7 || true > /dev/null 2>&1

echo "Iniciando container dspace7"
docker compose -f source/DSpace-dspace-7.6/docker-compose_restart.yml up --build -d