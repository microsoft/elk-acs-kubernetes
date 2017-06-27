#!/bin/bash
#
# create Kubernetes cluster on ACS.

export PATH=/usr/local/bin/:$PATH

#######################################
# create Kubernetes cluster on ACS.
# Arguments:
#   Resource group
#   Location
#   Dns prefix
#   Cluster name
# Returns:
#   None
#######################################
createK8sAcs() {
  RESOURCE_GROUP=$1
  LOCATION=$2
  DNS_PREFIX=$3
  CLUSTER_NAME=$4
  if $(az group exists -n $RESOURCE_GROUP)
    then echo $RESOURCE_GROUP " exists at " $LOCATION
  else 
    az group create --name=$RESOURCE_GROUP --location=$LOCATION
  fi
  az acs create --orchestrator-type=kubernetes --resource-group $RESOURCE_GROUP --name=$CLUSTER_NAME --dns-prefix=$DNS_PREFIX --generate-ssh-keys
}

createK8sAcs <resource-group> \
             <location> \
             <dns-prefix> \
             <cluster-name>