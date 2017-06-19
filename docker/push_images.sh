#! /bin/bash
registry_server=elkacr.azurecr.io
registry_username=elkacr
registry_password='<password>'

docker login --username ${registry_username} --password ${registry_password} ${registry_server}

docker build -t ${registry_server}/elasticsearch:1.0.0 ./elasticsearch
docker push ${registry_server}/elasticsearch:1.0.0
docker build -t ${registry_server}/kibana:1.0.0 ./kibana
docker push ${registry_server}/kibana:1.0.0
docker build -t ${registry_server}/logstash:1.0.0 ./logstash
docker push ${registry_server}/logstash:1.0.0
docker build -t ${registry_server}/filebeat:1.0.0 ./filebeat
docker push ${registry_server}/filebeat:1.0.0
