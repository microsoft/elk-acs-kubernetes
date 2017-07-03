# Deploy ELK on Kubernetes in Azure Container Service (ACS)

This repository contains tools and helm charts to help deploy the [ELK stack](https://www.elastic.co/products) on [Kubernetes](https://kubernetes.io/) in [Azure Container Service (ACS)](https://docs.microsoft.com/azure/container-service/).

## Prerequesites

* An Azure subscription. If you do not have an Azure subscription, you can sign up for a [Azure Free Trial Subscription](https://azure.microsoft.com/offers/ms-azr-0044p/)

* Install the Azure Command Line Interface (CLI) by following the instructions in the [Install Azure CLI 2.0](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) article.

* Install the Kubernetes `kubectl` Command Line Interface using the Azure CLI:

   ```shell
   az acs kubernetes install-cli
   ```

## Provision a Kubernetes cluster and create Azure storage accounts and containers

Enter the following commands in a terminal window to provision a Kubernetes cluster, create an Azure storage account, and a container for the Azure Container Service:

```shell
RESOURCE_GROUP=elk-rg
LOCATION=westus
DNS_PREFIX=elk-kube-acs
CLUSTER_NAME=elk-kube-acs-cluster
STORAGE_ACCOUNT=azdisksa
ACR_NAME=elkacr

az group create --name=$RESOURCE_GROUP --location=$LOCATION

az acs create --orchestrator-type=kubernetes --resource-group $RESOURCE_GROUP --name=$CLUSTER_NAME --dns-prefix=$DNS_PREFIX --generate-ssh-keys

az storage account create --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP --sku Standard_GRS

export AZURE_STORAGE_CONNECTION_STRING="$(az storage account show-connection-string --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP -o tsv)"

az storage container create -n vhds

az acr create --name $ACR_NAME --resource-group $RESOURCE_GROUP --sku Basic

az acr update -n $ACR_NAME --admin-enabled true
```

**Note**: If you specify different values for the `$RESOURCE_GROUP`, `$LOCATION`, `$DNS_PREFIX`, `$CLUSTER_NAME`, `$STORAGE_ACCOUNT` and `$ACR_NAME` variables, you will need to update the corresponding fields in your `values.yaml` and `config.yaml` files.

## Connect to Kubernetes cluster

* Import your Kubernetes cluster credentials:

   ```shell
   az acs kubernetes get-credentials --resource-group=$RESOURCE_GROUP --name=$CLUSTER_NAME
   ```

* List all the nodes in the cluster:

   ```shell
   kubectl get nodes
   ```

## Verify your setup

* Launch a HTTP proxy to access Kubernetes API

   ```shell
   kubectl proxy
   ```

* View all workloads by browsing to `http://localhost:8001/ui`

## Install Helm

Install the Helm client by following the instructions in the [Quickstart Guide](https://github.com/kubernetes/helm/blob/master/docs/quickstart.md)

## Build and push your ELK docker images to container registry

* Retrieve the credential of container registry from `elkacr.azurecr.io`:

   ```shell
   az acr credential show --name $ACR_NAME --resource-group $RESOURCE_GROUP
   ```

* Replace your password in the `push_images.sh` script, and then run the script in a terminal window.

## Deploy your ELK cluster

* Open the `start-elk.sh` script in your `helm-charts` directory with a text editor, and replace the placeholders with valid password and email of the continer registry you just created.

* Run the `./start-elk.sh` script in a terminal window.

* Browse to `http://localhost:8001/ui` to monitor the status of deployments.

* Run the following command in a terminal window to get the public endpoint of Kibana service and access it from browser:

   ```shell
   kubectl get svc --namespace elk-cluster-ns
   ```

## Deploy `filebeat` to collect Kubernetes cluster logs for visualization in Kibana

* Run the following command in a terminal window to get the public endpoint of Kibana service and access it from browser:

   ```shell
   helm install filebeat
   ```

* Click the link for the **Kibana** service in your web browser and create and index pattern.

* Click the link for **Discover** in the left pane to find the log streams.

## Delete your Helm releases

* Run the following command in a terminal window to delete your Helm releases:

   ```shell
   helm list | awk '$1!="NAME" { print $1 }' | xargs helm delete
   ```
   **Note**: This command will delete *all* of your existing Helm releases.

## Auto-scaling

* Kubernetes supports horizontal pod autoscaler with `kubectl autoscale`. For example, to auto scale a deployment with the number of pods between 2 and 5 and target CPU utilization 80%, run the following command in a terminal window:

   ```shell
   kubectl autoscale deployment <deployment_name> --min=2 --max=5 --cpu-percent=80
   ```

* Currently, auto-scaling of agent nodes in cluster in Azure Container Service is not supported. To manually change the number of agent nodes, run the following command in a terminal window:

   ```shell
   az acs scale -g <resource_group> -n <cluster_name> --new-agent-count <number>
   ```

* Kubernetes clusters created with the [acs-engine](https://github.com/Azure/acs-engine) in Azure support auto-scaling.
