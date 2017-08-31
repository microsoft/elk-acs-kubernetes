#!/usr/bin/env bash

# terminate once a command failed
set -e

echo $@

while getopts ':r:u:p:d:l:s:a:b:' arg
do
     case ${arg} in
        r) registryUrl=${OPTARG};;
        u) registryUsername=${OPTARG};;
        p) registryPassword=${OPTARG};;
        d) storageAccountName=${OPTARG};;
        l) resourceLocation=${OPTARG};;
        s) storageAccountSku=${OPTARG};;
        a) kibanaUsername=${OPTARG};;
        b) kibanaPassword=${OPTARG};;
     esac
done

export TAG='latest'
export REGISTRY_URL=${registryUrl}
export STORAGE_ACCOUNT=${storageAccountName}
export STORAGE_LOCATION=${resourceLocation}
export STORAGE_SKU=${storageAccountSku}
export NAMESPACE=elk-cluster-ns
export USERNAME=${kibanaUsername}
export PASSWORD=${kibanaPassword}

# substitute environment variables
cat config.yaml | envsubst > effect.yaml

helm install -f effect.yaml ns

echo ${registryUsername}
if [ ! -z ${registryUsername} ]; then
    # create secret
    registry_name=azure-registry
    registry_email=example@example.com

    kubectl --namespace=${NAMESPACE} create secret docker-registry ${registry_name} \
    --docker-server=${registryUrl} \
    --docker-username=${registryUsername} \
    --docker-password=${registryPassword} \
    --docker-email=${registry_email}
fi

# create Elasticsearch
helm install -f effect.yaml es

# create Kibana
helm install -f effect.yaml kibana

# create Logstash
helm install -f effect.yaml logstash