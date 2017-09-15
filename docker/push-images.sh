#!/usr/bin/env bash

set -e

echo $@

while getopts ':r:u:p:a:b:c:d:e:f:' arg
do
     case ${arg} in
        r) registryUrl=${OPTARG};;
        u) registryUsername=${OPTARG};;
        p) registryPassword=${OPTARG};;
        a) diagEvtHubNs=${OPTARG};;
        b) diagEvtHubNa=${OPTARG};;
        c) diagEvtHubKey=${OPTARG};;
        d) diagEvtHubEntPa=${OPTARG};;
        e) diagEvtHubPartNum=${OPTARG};;
        f) diagEvtHubThreadWait=${OPTARG};;
     esac
done

docker login --username ${registryUsername} --password ${registryPassword} ${registryUrl}

docker build -t ${registryUrl}/elasticsearch ./elasticsearch
docker push ${registryUrl}/elasticsearch
docker build -t ${registryUrl}/kibana ./kibana
docker push ${registryUrl}/kibana
docker build -t ${registryUrl}/logstash ./logstash --build-arg DIAG_EVT_HUB_NS=${diagEvtHubNs} \
                                                   --build-arg DIAG_EVT_HUB_KEY_NAME=${diagEvtHubNa} \
                                                   --build-arg DIAG_EVT_HUB_ACC_KEY=${diagEvtHubKey} \
                                                   --build-arg DIAG_EVT_HUB_ENT_PATH=${diagEvtHubEntPa} \
                                                   --build-arg DIAG_EVT_HUB_PART=${diagEvtHubPartNum} \
                                                   --build-arg DIAG_EVT_HUB_THR_WAIT=${diagEvtHubThreadWait}
docker push ${registryUrl}/logstash
docker build -t ${registryUrl}/filebeat:1.0.0 ./filebeat
docker push ${registryUrl}/filebeat
