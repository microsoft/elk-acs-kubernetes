#!/bin/bash
#
# create Storage account and Azure container registry.

export PATH=/usr/local/bin/:$PATH

#######################################
# create Storage account and Azure container registry.
# Arguments:
#   Resource group
#   Location
#   Storage account
#   Azure container registry name
# Returns:
#   None
#######################################
createSaAcr() {
  RESOURCE_GROUP=$1
  LOCATION=$2
  STORAGE_ACCOUNT=$3
  ACR_NAME=$4
  if $(az group exists -n $RESOURCE_GROUP)
    then echo $RESOURCE_GROUP " exists at " $LOCATION
  else 
    az group create --name=$RESOURCE_GROUP --location=$LOCATION
  fi
  az storage account create --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP --sku Standard_GRS
  export AZURE_STORAGE_CONNECTION_STRING="$(az storage account show-connection-string --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP -o tsv)"
  az storage container create -n vhds
  az acr create --name $ACR_NAME --resource-group $RESOURCE_GROUP --sku Basic
  az acr update -n $ACR_NAME --admin-enabled true
}

createSaAcr <resource-group> \
            <location> \
            <storage-account> \
            <acr-name>