# Deploy ELK on Kubernetes in Azure Container Service
This repo contains tools and helm charts to help deploy ELK stack on Kubernetes in Azure Container Service.
## Prerequesites
* An Azure subscription. You can get a [Azure Free Trial Subscription](http://https://azure.microsoft.com/en-us/offers/ms-azr-0044p/?v=17.23h).
* Provision a Kubernetes cluster, create storage account/container and Azure Container Service:
    * `RESOURCE_GROUP=elk-rg`
    * `LOCATION=westus`
    * `DNS_PREFIX=elk-kube-acs`
    * `CLUSTER_NAME=elk-kube-acs-cluster`
    * `STORAGE_ACCOUNT=azdisksa`
    * `ACR_NAME=elkacr`
    * `az group create --name=$RESOURCE_GROUP --location=$LOCATION`
    * `az acs create --orchestrator-type=kubernetes --resource-group $RESOURCE_GROUP --name=$CLUSTER_NAME --dns-prefix=$DNS_PREFIX --generate-ssh-keys`
    * `az storage account create --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP --sku Standard_GRS`
    * `export AZURE_STORAGE_CONNECTION_STRING="$(az storage account show-connection-string --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP -o tsv)"`
    * `az storage container create -n vhds`
    * `az acr create --name $ACR_NAME --resource-group $RESOURCE_GROUP --sku Basic`
    * `az acr update -n $ACR_NAME --admin-enabled true`
* If different `$RESOURCE_GROUP`, `$LOCATION`, `$DNS_PREFIX`, `$CLUSTER_NAME`, `$STORAGE_ACCOUNT` and `$ACR_NAME` have been specified, the corresponding fileds in all values.yaml as well as config.yaml need to be updated.

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

## Auto scaling
* Kubernetes supports horizontal pod autoscaler with `kubectl autoscale`. For example, auto scale a deployment with the number of pods between 2 and 5, target CPU utilization 80%. Run `kubectl autoscale deployment <deployment_name> --min=2 --max=5 --cpu-percent=80`.
* Currently, auto scaling of agent nodes in cluster in Azure Container Service is not supported. To manually change the number of agent nodes, run the command `az acs scale -g <resource_group> -n <cluster_name> --new-agent-count <number>`.
* Kubernetes cluster created with [acs-engine](https://github.com/Azure/acs-engine) in Azure supports auto scaling.
