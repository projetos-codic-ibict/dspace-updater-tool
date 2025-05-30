#!/bin/bash

{

cp ./dockerfiles/old-solr-xml.xml ./dspace-install-dir/webapps/solr/WEB-INF/web.xml


mkdir -p ./tmp

docker pull tomcat:8.5.89-jdk8-temurin-jammy
docker rm -f tomcatsolr || true
docker rm -f dspace8solr || true
docker rm -f downloadsolrdata || true


docker network create oldsolr
echo "Setting up a Tomcat with the old Solr"
docker run -d --net oldsolr --name tomcatsolr -p 7777:8080 -v $(pwd)/dspace-install-dir:/dspace -v $(pwd)/dspace-install-dir/webapps/solr:/usr/local/tomcat/webapps/solr -w /dspace tomcat:8.5.89-jdk8-temurin-jammy

timeout 20s grep -q ' Server startup in ' <(docker logs tomcatsolr --follow)


echo "Generating the solr dump"
#sleep 10000

docker run --rm --net oldsolr -v $(pwd):/unzip  --name downloadsolrdata -w /unzip kubeless/unzip curl 'http://tomcatsolr:8080/solr/statistics/select?q=*%3A*&rows=99999999&wt=csv&indent=true&&fl=owner%2Csubmitter%2CisBot%2Cstatistics_type%2CpreviousWorkflowStep%2CworkflowItemId%2Cip%2Cdns%2CworkflowStep%2CuserAgent%2Ctype%2Cactor%2Creferrer%2Cuid%2CowningItem%2CbundleName%2Cid%2Ctime%2Cepersonid%2CowningColl%2CowningComm' -o ./tmp/export.csv -L


sudo split -l 100000 ./tmp/export.csv ./tmp/solr_

echo "Handling the solr dump files"
for file in ./tmp/solr_*
do
  if  [ "${file##*/}" != "solr_aa" ]; then
    docker run --rm -e PARCIAL_SOLR=${file} -v $(pwd)/tmp:/tmp -w /tmp intel/qat-crypto-base:qatsw-ubuntu \
      sed -i '1s/^/owner,submitter,isBot,statistics_type,previousWorkflowStep,workflowItemId,ip,dns,workflowStep,userAgent,type,actor,referrer,uid,owningItem,bundleName,id,time,epersonid,owningColl,owningComm\n/' ${file##*/}
  fi
done

rm -rf ./dspace-install-dir/solr
rm -rf ./dspace-install-dir/webapps

docker rm -f tomcatsolr


} >>./execution.log 2>&1
