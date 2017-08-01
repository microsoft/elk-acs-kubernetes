#!/usr/bin/env bash

# terminate once a command failed
set -e

while getopts ':r:u:p:d:l:s' arg
do
     case ${arg} in
        r) registryUrl=${OPTARG};;
        u) registryUsername=${OPTARG};;
        p) registryPassword=${OPTARG};;
        d) storageAccountName=${OPTARG};;
        l) resourceLocation=${OPTARG};;
        s) storageAccountSku=${OPTARG};;
     esac
done

export TAG='latest'
export STORAGE_ACCOUNT=${storageAccountName}
export STORAGE_LOCATION=${resourceLocation}
export STORAGE_SKU=${storageAccountSku}
# substitute environment variables
cat config.yaml | envsubst > effect.yaml

# create namespace
namespace=elk-cluster-ns

helm install -f config.yaml ns

if [ ! -z ${registryUsername} ]; then
    # create secret
    registry_name=azure-registry
    registry_email=example@example.com

    kubectl --namespace=${namespace} create secret docker-registry ${registry_name} \
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
