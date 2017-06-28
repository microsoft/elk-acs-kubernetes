#! /bin/bash

set -e

REGISTRY_NAME=$1
REGISTRY_PASS=$2
export STORAGE_ACCOUNT=$3
export STORAGE_LOCATION=$4

bash docker/push-images.sh $REGISTRY_NAME $REGISTRY_PASS
bash helm-charts/start-elk.sh $REGISTRY_NAME $REGISTRY_PASS
