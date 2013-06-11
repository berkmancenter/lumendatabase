#!/bin/sh

ELASTICSEARCH_RUNNING=`lsof -i:9200`

if [ "$ELASTICSEARCH_RUNNING" ];
then
  exit 0
fi

start_elasticsearch() {
  cd ./tmp/elasticsearch && exec ./bin/elasticsearch -f
}

write_elasticsearch_config() {
cat > elasticsearch/config/elasticsearch.yml <<End-of-config

cluster.name: chillingeffects
discovery.zen.ping.multicast.enabled: false

End-of-config
}

if [ -d './tmp/elasticsearch' ]
then
  start_elasticsearch
else
  cd ./tmp
  curl https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.1.tar.gz \
    -o elasticsearch.tgz
  tar xvfz elasticsearch.tgz
  mv elasticsearch-0.90.1 elasticsearch

  write_elasticsearch_config

  cd ..
  start_elasticsearch
fi
