# Deploy ELK on Kubernetes in Azure Container Service
This repo contains tools and helm charts to help deploy ELK stack on Kubernetes in Azure Container Service.
## Prerequesites
* An Azure subscription. You can get a [Azure Free Trial Subscription](http://https://azure.microsoft.com/en-us/offers/ms-azr-0044p/?v=17.23h).
* Provision a Kubernetes cluster, create storage account/container and Azure Container Service:
    * `RESOURCE_GROUP=elk-rg`
    * `LOCATION=westus`
    * `az group create --name=$RESOURCE_GROUP --location=$LOCATION`
    * `DNS_PREFIX=elk-kube-acs`
    * `CLUSTER_NAME=elk-kube-acs-cluster`
    * `az acs create --orchestrator-type=kubernetes --resource-group $RESOURCE_GROUP --name=$CLUSTER_NAME --dns-prefix=$DNS_PREFIX --generate-ssh-keys`
    * `STORAGE_ACCOUNT=azdisksa`
    * `az storage account create --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP --sku Standard_GRS`
    * `export AZURE_STORAGE_CONNECTION_STRING="$(az storage account show-connection-string --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP -o tsv)"`
    * `az storage container create -n vhds`
    * `ACR_NAME=elkacr`
    * `az acr create --name $ACR_NAME --resource-group $RESOURCE_GROUP --sku Basic`
    * `az acr update -n $ACR_NAME --admin-enabled true`

## Connect to Kubernetes cluster
* Install `kubectl`
    * `az acs kubernetes install-cli`
* Import Kubernetes cluster credentials
    * `az acs kubernetes get-credentials --resource-group=$RESOURCE_GROUP --name=$CLUSTER_NAME`
* List all the nodes in the cluster
    * `kubectl get nodes`

## Verify your setup
* Launch a HTTP proxy to access Kubernetes API
    * `kubectl proxy`
* View all workloads by browsing to `http://localhost:8001/ui`

## Install Helm
* Refer to [Quickstart Guide](https://github.com/kubernetes/helm/blob/master/docs/quickstart.md)

## Build and push your ELK docker images to container registry
* Get the credential of registry `elkacr.azurecr.io`:
    * `az acr credential show --name $ACR_NAME --resource-group $RESOURCE_GROUP`
* Replace password in `push_images.sh` and run it.

## Deploy ELK cluster
* Go to `helm-charts` and modify start-elk.sh to replace placeholders with valid password and email of the registry you just created.
* Run `./start-elk.sh`
* Browse to `http://localhost:8001/ui` to monitor the status of deployments.
* Run `kubectl get svc --namespace elk-cluster-ns` and get the public endpoint of Kibana service and access it from browser.

## Deploy filebeat to collect Kubernetes cluster logs for visualization in Kibana.
* Run `helm install filebeat`
* Go to Kibana service in browser and create index pattern.
* Go to Discover in the left pane to find log streams.

## Delete your Helm releases
* Run `helm list | awk '$1!="NAME" { print $1 }' | xargs helm delete` to delete all your Helm releases
Note: the command will delete All your existing Helm releases.