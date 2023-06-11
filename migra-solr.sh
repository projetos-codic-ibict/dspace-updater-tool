#!/bin/bash
#echo "Press CTRL+C to proceed."
#trap "pkill -f 'sleep 1h'" INT
#trap "set +x ; sleep 1h ; set -x" DEBUG

#: <<'END'

cp ./dockerfiles/old-solr-xml.xml ./dspace-install-dir/webapps/solr/WEB-INF/web.xml


rm ./tmp/*
docker pull tomcat:8.5.89-jdk8-temurin-jammy
docker rm -f tomcatsolr || true
docker rm -f dspace7solr || true
docker rm -f downloadsolrdata || true


echo "Setting up a Tomcat with the old Solr"
docker run -d --net="host" -p 127.0.0.1:8080:8080 --name tomcatsolr -v $(pwd)/dspace-install-dir:/dspace -v $(pwd)/dspace-install-dir/webapps/solr:/usr/local/tomcat/webapps/solr -w /dspace tomcat:8.5.89-jdk8-temurin-jammy


echo "Starting the new solr"
docker compose -f ./dockerfiles/docker-compose_migration.yml up dspace7solr --build -d


echo "Generating the solr dump"

#sleep 2
#docker run --rm --net="host"  -v $(pwd):/unzip  --name downloadsolrdata -w /unzip kubeless/unzip \
#    && curl 'http://localhost:8080/solr/statistics/select?q=*%3A*&rows=99999999&wt=csv&indent=true&&fl=owner%2Csubmitter%2CisBot%2Cstatistics_type%2CpreviousWorkflowStep%2CworkflowItemId%2Cip%2Cdns%2CworkflowStep%2CuserAgent%2Ctype%2Cactor%2Creferrer%2Cuid%2CowningItem%2CbundleName%2Cid%2Ctime%2Cepersonid%2CowningColl%2CowningComm' -o ./tmp/export.csv -L


split -l 100000 ./tmp/export.csv ./tmp/solr_

docker exec dspace7solr solr create -c statistics
#docker cp ./dspace-install-dir/solr/statistics/conf/solrconfig.xml dspace7solr:/var/solr/data/statistics/conf

echo "Reloading SOLR Core"
docker run --net="host" --rm -e file=${file} -v $(pwd):/unzip -w /unzip kubeless/unzip \
   && curl "http://localhost:8983/solr/admin/cores?action=RELOAD&core=statistics"


#END


echo "Handling the solr dump files"
for file in ./tmp/solr_*
do
	echo "Importing the solr dump file: ${file##*/}"
  if  [ "${file##*/}" != "solr_aa" ]; then
    echo "Adding header to file ${file##*/}"
    docker run --rm -e PARCIAL_SOLR=${file} -v $(pwd)/tmp:/tmp -w /tmp intel/qat-crypto-base:qatsw-ubuntu \
      sed -i '1s/^/owner,submitter,isBot,statistics_type,previousWorkflowStep,workflowItemId,ip,dns,workflowStep,userAgent,type,actor,referrer,uid,owningItem,bundleName,id,time,epersonid,owningColl,owningComm \n/' ${file##*/}
  fi

  echo "Sending file ${file##*/} to Solr..."

  docker run --rm --network="dspacenet" -e file=${file} -v $(pwd):/unzip -w /unzip kubeless/unzip \
     && curl 'http://localhost:8983/solr/statistics/update?commit=true&commitWithin=1000' --data-binary @"${file}" -H 'Content-type:application/csv'
done

rm ./tmp/*
docker rm -f tomcatsolr || true
