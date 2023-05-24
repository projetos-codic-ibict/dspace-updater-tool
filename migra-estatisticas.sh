#!/bin/bash

mkdir -p ./dspace-install-dir/solr-conversion-files/libs

docker run --rm -v $(pwd):/unzip -w /unzip kubeless/unzip \
 && curl https://repo1.maven.org/maven2/org/apache/lucene/lucene-core/4.10.4/lucene-core-4.10.4.jar -o ./dspace-install-dir/solr-conversion-files/libs/lucene-core-4.jar -L \
 && curl https://repo1.maven.org/maven2/org/apache/lucene/lucene-backward-codecs/4.10.4/lucene-backward-codecs-4.10.4.jar -o ./dspace-install-dir/solr-conversion-files/libs/back-lucene-core-4.jar -L \
 && curl https://repo1.maven.org/maven2/org/apache/lucene/lucene-core/5.5.4/lucene-core-5.5.4.jar -o ./dspace-install-dir/solr-conversion-files/libs/lucene-core-5.jar -L \
 && curl https://repo1.maven.org/maven2/org/apache/lucene/lucene-backward-codecs/5.5.4/lucene-backward-codecs-5.5.4.jar -o ./dspace-install-dir/solr-conversion-files/libs/back-lucene-core-5.jar -L \
 && curl https://repo1.maven.org/maven2/org/apache/lucene/lucene-core/6.6.0/lucene-core-6.6.0.jar -o ./dspace-install-dir/solr-conversion-files/libs/lucene-core-6.jar -L \
 && curl https://repo1.maven.org/maven2/org/apache/lucene/lucene-backward-codecs/6.6.0/lucene-backward-codecs-6.6.0.jar -o ./dspace-install-dir/solr-conversion-files/libs/back-lucene-core-6.jar -L

echo "Atualizando indices Solr para versão 4... (aguarde)"
docker run --rm -v $(pwd):/install-dir -w /install-dir adoptopenjdk/openjdk11 \
  pwd && ls -lsah &&
  java -cp ./dspace-install-dir/solr-conversion-files/libs/lucene-core-4.jar:./dspace-install-dir/solr-conversion-files/libs/back-lucene-core-4.jar org.apache.lucene.index.IndexUpgrader -delete-prior-commits ./dspace-install-dir/solr/authority/data/index \
  && java -cp ./dspace-install-dir/solr-conversion-files/libs/lucene-core-4.jar:./dspace-install-dir/solr-conversion-files/libs/back-lucene-core-4.jar org.apache.lucene.index.IndexUpgrader -delete-prior-commits ./dspace-install-dir/solr/oai/data/index \
  && java -cp ./dspace-install-dir/solr-conversion-files/libs/lucene-core-4.jar:./dspace-install-dir/solr-conversion-files/libs/back-lucene-core-4.jar org.apache.lucene.index.IndexUpgrader -delete-prior-commits ./dspace-install-dir/solr/search/data/index \
  && java -cp ./dspace-install-dir/solr-conversion-files/libs/lucene-core-4.jar:./dspace-install-dir/solr-conversion-files/libs/back-lucene-core-4.jar org.apache.lucene.index.IndexUpgrader -delete-prior-commits ./dspace-install-dir/solr/statistics/data/index
  
echo "Atualizando indices Solr para versão 5... (aguarde)"
docker run --rm -v $(pwd):/install-dir -w /install-dir adoptopenjdk/openjdk11 \
  java -cp ./dspace-install-dir/solr-conversion-files/libs/lucene-core-5.jar:./dspace-install-dir/solr-conversion-files/libs/back-lucene-core-5.jar org.apache.lucene.index.IndexUpgrader -delete-prior-commits ./dspace-install-dir/solr/authority/data/index \
  && java -cp ./dspace-install-dir/solr-conversion-files/libs/lucene-core-5.jar:./dspace-install-dir/solr-conversion-files/libs/back-lucene-core-5.jar org.apache.lucene.index.IndexUpgrader -delete-prior-commits ./dspace-install-dir/solr/oai/data/index \
  && java -cp ./dspace-install-dir/solr-conversion-files/libs/lucene-core-5.jar:./dspace-install-dir/solr-conversion-files/libs/back-lucene-core-5.jar org.apache.lucene.index.IndexUpgrader -delete-prior-commits ./dspace-install-dir/solr/search/data/index \
  && java -cp ./dspace-install-dir/solr-conversion-files/libs/lucene-core-5.jar:./dspace-install-dir/solr-conversion-files/libs/back-lucene-core-5.jar org.apache.lucene.index.IndexUpgrader -delete-prior-commits ./dspace-install-dir/solr/statistics/data/index
  
echo "Atualizando indices Solr para versão 6... (aguarde)"
docker run --rm -v $(pwd):/install-dir -w /install-dir adoptopenjdk/openjdk11 \
  java -cp ./dspace-install-dir/solr-conversion-files/libs/lucene-core-6.jar:./dspace-install-dir/solr-conversion-files/libs/back-lucene-core-6.jar org.apache.lucene.index.IndexUpgrader -delete-prior-commits ./dspace-install-dir/solr/authority/data/index \
  && java -cp ./dspace-install-dir/solr-conversion-files/libs/lucene-core-6.jar:./dspace-install-dir/solr-conversion-files/libs/back-lucene-core-6.jar org.apache.lucene.index.IndexUpgrader -delete-prior-commits ./dspace-install-dir/solr/oai/data/index \
  && java -cp ./dspace-install-dir/solr-conversion-files/libs/lucene-core-6.jar:./dspace-install-dir/solr-conversion-files/libs/back-lucene-core-6.jar org.apache.lucene.index.IndexUpgrader -delete-prior-commits ./dspace-install-dir/solr/search/data/index \
  && java -cp ./dspace-install-dir/solr-conversion-files/libs/lucene-core-6.jar:./dspace-install-dir/solr-conversion-files/libs/back-lucene-core-6.jar org.apache.lucene.index.IndexUpgrader -delete-prior-commits ./dspace-install-dir/solr/statistics/data/index