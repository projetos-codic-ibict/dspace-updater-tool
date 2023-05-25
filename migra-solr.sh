#!/bin/bash

mkdir -p ./dspace-install-dir/solr-conversion-files/libs
export URL_BASE=https://repo1.maven.org/maven2/org/apache/lucene
export DEST_FOLDER=./dspace-install-dir/solr-conversion-files/libs

docker run --rm -e $URL_BASE:URL_BASE -e $DEST_FOLDER:DEST_FOLDER -v $(pwd):/unzip -w /unzip kubeless/unzip \
 && curl $URL_BASE/lucene-core/4.10.4/lucene-core-4.10.4.jar -o $DEST_FOLDER/lucene-core-4.jar -L \
 && curl $URL_BASE/lucene-backward-codecs/4.10.4/lucene-backward-codecs-4.10.4.jar -o $DEST_FOLDER/back-lucene-core-4.jar -L \
 && curl $URL_BASE/lucene-core/5.5.4/lucene-core-5.5.4.jar -o $DEST_FOLDER/lucene-core-5.jar -L \
 && curl $URL_BASE/lucene-backward-codecs/5.5.4/lucene-backward-codecs-5.5.4.jar -o $DEST_FOLDER/back-lucene-core-5.jar -L \
 && curl $URL_BASE/lucene-core/6.6.0/lucene-core-6.6.0.jar -o $DEST_FOLDER/lucene-core-6.jar -L \
 && curl $URL_BASE/lucene-backward-codecs/6.6.0/lucene-backward-codecs-6.6.0.jar -o $DEST_FOLDER/back-lucene-core-6.jar -L \
 && curl $URL_BASE/lucene-core/7.7.0/lucene-core-7.7.0.jar -o $DEST_FOLDER/lucene-core-7.jar -L \
 && curl $URL_BASE/lucene-backward-codecs/7.7.0/lucene-backward-codecs-7.7.0.jar -o $DEST_FOLDER/back-lucene-core-7.jar -L \
 && curl $URL_BASE/lucene-core/8.11.1/lucene-core-8.11.1.jar -o $DEST_FOLDER/lucene-core-8.jar -L \
 && curl $URL_BASE/lucene-backward-codecs/8.11.1/lucene-backward-codecs-8.11.1.jar -o $DEST_FOLDER/back-lucene-core-8.jar -L


for version in 4 5 6 7 8
do
   echo "Atualizando indices Solr para versão ${version}... (aguarde)"
   docker run --rm -e $version:version -v $(pwd):/install-dir -w /install-dir adoptopenjdk/openjdk11 \
     && java -cp ./dspace-install-dir/solr-conversion-files/libs/lucene-core-${version}.jar:./dspace-install-dir/solr-conversion-files/libs/back-lucene-core-${version}.jar org.apache.lucene.index.IndexUpgrader -delete-prior-commits ./dspace-install-dir/solr/authority/data/index \
     && java -cp ./dspace-install-dir/solr-conversion-files/libs/lucene-core-${version}.jar:./dspace-install-dir/solr-conversion-files/libs/back-lucene-core-${version}.jar org.apache.lucene.index.IndexUpgrader -delete-prior-commits ./dspace-install-dir/solr/oai/data/index \
     && java -cp ./dspace-install-dir/solr-conversion-files/libs/lucene-core-${version}.jar:./dspace-install-dir/solr-conversion-files/libs/back-lucene-core-${version}.jar org.apache.lucene.index.IndexUpgrader -delete-prior-commits ./dspace-install-dir/solr/search/data/index \
     && java -cp ./dspace-install-dir/solr-conversion-files/libs/lucene-core-${version}.jar:./dspace-install-dir/solr-conversion-files/libs/back-lucene-core-${version}.jar org.apache.lucene.index.IndexUpgrader -delete-prior-commits ./dspace-install-dir/solr/statistics/data/index
done

