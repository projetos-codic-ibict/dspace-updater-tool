#/bin/bash

echo "Este procedimento irá re-utilizar o dump do postgres\n"

rm dspace-7.5.zip || true

docker rm -f dspace-angular || true
docker rmi -f docker_dspace-angular || true

./frontend_migra-para-dspace7.sh