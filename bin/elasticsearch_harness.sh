#!/bin/sh

ELASTICSEARCH_RUNNING=`lsof -i:9200`

if [ "$ELASTICSEARCH_RUNNING" ];
then
  echo 'Elastic search already running'
  exit 0
fi

start_elasticsearch() {
  echo 'Starting elasticsearch...'
  cd elasticsearch
  exec ./bin/elasticsearch -f
}

write_elasticsearch_config() {
  echo 'Writing elasticsearch config...'
  cat > elasticsearch/config/elasticsearch.yml <<End-of-config

cluster.name: chillingeffects
discovery.zen.ping.multicast.enabled: false

End-of-config
}

install_elasticsearch() {
  echo 'Installing elasticsearch under ./tmp...'
  curl --silent --output elasticsearch.tgz \
    'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.1.tar.gz'

  tar xfz elasticsearch.tgz

  mv elasticsearch-0.90.1 elasticsearch
}

set -e

cd ./tmp

if [ -d './elasticsearch' ]
then
  start_elasticsearch
else
  install_elasticsearch

  write_elasticsearch_config

  start_elasticsearch
fi
