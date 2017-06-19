# Deploy ELK on Kubernetes in Azure Container Service
This repo contains tools and helm charts to help deploy ELK stack on Kubernetes in Azure Container Service.
## Prerequesites
* An Azure subscription. You can get a [Azure Free Trial Subscription](http://https://azure.microsoft.com/en-us/offers/ms-azr-0044p/?v=17.23h).
* Provision a Kubernetes cluster, create storage account/container and Azure Container Service:
    * `RESOURCE_GROUP=elk-rg`
    * `Location=westus`
    * `az group create --name=$RESOURCE_GROUP --location=$LOCATION`
    * `DNS_PREFIX=elk-kube-acs`
    * `CLUSTER_NAME=elk-kube-acs-cluster`
    * `az acs create --orchestrator-type=kubernetes --resource-group $RESOURCE_GROUP --name=$CLUSTER_NAME --dns-prefix=$DNS_PREFIX --generate-ssh-keys`
    * `STORAGE_ACCOUNT=azdisksa`
    * `export AZURE_STORAGE_CONNECTION_STRING="$(az storage account show-connection-string --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP -o tsv)"`
    * `az storage container create -n vhds`
    * `ACR_NAME=elkacr`
    * `az acr create --name $ACR_NAME --resource-group $RESOURCE_GROUP --sku Basic`

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
* Create a container registry in [Azure Container Service](https://docs.microsoft.com/en-us/azure/container-service/container-service-deployment).
* Access keys blade. Get your Username and password for authentication to ACR.
* Replace registry URL, username and password in `push_images.sh` and run it.

## Deploy ELK cluster
* Go to `helm-elk` and modify start-elk.sh and config.yml to replace placeholders with valid URL, username, password and email of the registry you just created.
* Run `./start-elk.sh`
* Browse to `http://localhost:8001/ui` to monitor the status of deployments.
* Run `kubectl get svc --namespace elk-cluster-ns` and get the public endpoint of Kibana service and access it from browser.

## Deploy filebeat to collect Kubernetes cluster logs for visualization in Kibana.
* Run `helm install filebeat`
* Go to Kibana service in browser and create index.
