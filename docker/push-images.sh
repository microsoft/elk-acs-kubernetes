#! /bin/bash
registry_server=$1.azurecr.io
registry_username=$1
registry_password=$2

docker login --username ${registry_username} --password ${registry_password} ${registry_server}

docker build -t ${registry_server}/elasticsearch:1.0.0 ./elasticsearch
docker push ${registry_server}/elasticsearch:1.0.0
docker build -t ${registry_server}/kibana:1.0.0 ./kibana
docker push ${registry_server}/kibana:1.0.0
docker build -t ${registry_server}/logstash:1.0.0 ./logstash
docker push ${registry_server}/logstash:1.0.0
docker build -t ${registry_server}/filebeat:1.0.0 ./filebeat
docker push ${registry_server}/filebeat:1.0.0
