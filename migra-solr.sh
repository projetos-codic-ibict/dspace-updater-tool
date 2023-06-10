#!/bin/bash

cp ./dockerfiles/old-solr-xml.xml ./dspace-install-dir/webapps/solr/WEB-INF/web.xml


rm ./tmp/*
docker pull tomcat:8.5.89-jdk8-temurin-jammy
docker rm -f tomcatsolr || true


echo "Setting up a Tomcat with the old Solr"
docker run -d -p 8080:8080 --network=solrexport --name tomcatsolr -v $(pwd)/dspace-install-dir:/dspace -v $(pwd)/dspace-install-dir/webapps/solr:/usr/local/tomcat/webapps/solr -w /dspace tomcat:8.5.89-jdk8-temurin-jammy


docker rm -f dspace7solr2

echo "Starting the new solr"
docker compose -f docker-solr.yml up --build -d


echo "Generating the solr dump"
### Todo: use docker image for curl, attention with: acces to localhost inside the container
##curl 'http://localhost:8080/solr/statistics/select?q=*%3A*&rows=99999999&wt=csv&indent=true&&fl=owner%2Csubmitter%2CisBot%2Cstatistics_type%2CpreviousWorkflowStep%2CworkflowItemId%2Cip%2Cdns%2CworkflowStep%2CuserAgent%2Ctype%2Cactor%2Creferrer%2Cuid%2CowningItem%2CbundleName%2Cid%2Ctime%2Cepersonid%2CowningColl%2CowningComm' -o ./tmp/export.csv -L

docker run --rm -v $(pwd):/unzip --network=solrexport -w /unzip kubeless/unzip \
   && curl curl 'http://solrexport:8080/solr/statistics/select?q=*%3A*&rows=99999999&wt=csv&indent=true&&fl=owner%2Csubmitter%2CisBot%2Cstatistics_type%2CpreviousWorkflowStep%2CworkflowItemId%2Cip%2Cdns%2CworkflowStep%2CuserAgent%2Ctype%2Cactor%2Creferrer%2Cuid%2CowningItem%2CbundleName%2Cid%2Ctime%2Cepersonid%2CowningColl%2CowningComm' -o ./tmp/export.csv -L


echo "Ending the old solr"
docker rm -f tomcatsolr

split -l 100000 ./tmp/export.csv ./tmp/solr_

docker exec dspace7solr2 solr create -c statistics

echo "Handling the solr dump files"
for file in ./tmp/solr_*
do
	echo "Importing the solr dump file: ${file##*/}"
  if  [ "${file##*/}" != "solr_aa" ]; then
    echo "Adding header to file ${file##*/}"
    docker run --rm -e PARCIAL_SOLR=${file} -v $(pwd)/tmp:/tmp -w /tmp intel/qat-crypto-base:qatsw-ubuntu \
      sed -i '1s/^/owner,submitter,isBot,statistics_type,previousWorkflowStep,workflowItemId,ip,dns,workflowStep,userAgent,type,actor,referrer,uid,owningItem,bundleName,id,time,epersonid,owningColl,owningComm \n/' ${file##*/}
  fi

  docker run --rm -e file=${file} -v $(pwd):/unzip --network=solrexport -w /unzip kubeless/unzip \
     && curl 'http://localhost:8983/solr/statistics/update?commit=true&commitWithin=1000' --data-binary @"${file}" -H 'Content-type:application/csv'

#  curl 'http://localhost:8983/solr/statistics/update?commit=true&commitWithin=1000' --data-binary @"${file}" -H 'Content-type:application/csv'
done

