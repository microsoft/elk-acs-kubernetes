#!/usr/bin/env bash

set -e

echo $@

while getopts ':r:u:p:' arg
do
     case ${arg} in
        r) registryUrl=${OPTARG};;
        u) registryUsername=${OPTARG};;
        p) registryPassword=${OPTARG};;
     esac
done

docker login --username ${registryUsername} --password ${registryPassword} ${registryUrl}

docker build -t ${registryUrl}/elasticsearch ./elasticsearch
docker push ${registryUrl}/elasticsearch
docker build -t ${registryUrl}/kibana ./kibana
docker push ${registryUrl}/kibana
docker build -t ${registryUrl}/logstash ./logstash
docker push ${registryUrl}/logstash
docker build -t ${registryUrl}/filebeat ./filebeat
docker push ${registryUrl}/filebeat
