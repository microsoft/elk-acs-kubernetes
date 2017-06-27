# Deploy ELK on Kubernetes in Azure
This repo contains tools and helm charts to help deploy ELK stack on Kubernetes in Azure.

## Prerequesites
* An Azure subscription. You can get a [Azure Free Trial Subscription](http://https://azure.microsoft.com/en-us/offers/ms-azr-0044p/?v=17.23h).
* A Kubernetes cluster, a storage account/container and Azure Container Registry.
    * [Create your service principal in Azure AD](https://docs.microsoft.com/en-us/azure/container-service/container-service-kubernetes-service-principal)
      * `az login`
      * `az account set --subscription "mySubscriptionID"`
      * `az group create -n "myResourceGroupName" -l "westus"`
      * `az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/mySubscriptionID/resourceGroups/myResourceGroupName"`
    * Update your resource group, location, dns prefix, cluster name in `./util/create-k8s-acs.sh`.
    * Update your resource group, location, storage account, acr name in `./util/create-sa-acr.sh`.
    * Update `$RESOURCE_GROUP`, `$LOCATION`, `$DNS_PREFIX`, `$CLUSTER_NAME`, `$STORAGE_ACCOUNT` and `$ACR_NAME` in all values.yaml as well as config.yaml files.
    * Run `./util/create-k8s-acs.sh` and `./util/create-sa-acr.sh`
    * Deploy a Kubernetes cluster on Azure Container Service.
      * Run `./util/create-sa-acr.sh` and `./util/create-k8s-acs.sh`.
    * Deploy a Kubernetes cluster on Azure with [acs-engine](https://github.com/Azure/acs-engine).
      * [Install acs-engine](https://github.com/Azure/acs-engine/blob/master/docs/acsengine.md#downloading-and-building-acs-engine)
      * [Generate SSH key](https://github.com/Azure/acs-engine/blob/master/docs/ssh.md#ssh-key-generation)
      * [Create Service Principal with AZ CLI](https://github.com/Azure/acs-engine/blob/master/docs/serviceprincipal.md)
      * Fork [acs-engine](https://github.com/Azure/acs-engine) repo and update `examples/kubernetes.json` to fill in dnsPrefix, ssh publicKeys and servicePrincipalProfile.
      * [Generate template](https://github.com/Azure/acs-engine/blob/master/docs/acsengine.md#generating-a-template)
      * [Deploy](https://github.com/Azure/acs-engine/blob/master/README.md#deployment-usage). Deployment name will be used for `acsdeployment` when deploying [acs-engine-autoscaler](https://github.com/kubernetes/charts/tree/master/stable/acs-engine-autoscaler).
      * Run `./util/create-sa-acr.sh`.

## Connect to Kubernetes cluster
* Kubernetes cluster in ACS
  * Install `kubectl`
      * `az acs kubernetes install-cli`
  * Import Kubernetes cluster credentials
      * `az acs kubernetes get-credentials --resource-group=<resource_group> --name=<cluster_name>`
  * List all the nodes in the cluster
      * `kubectl get nodes`
* Kubernetes cluster created with acs-engine
  * Update `MASTER_HOST`, `CA_CERT`, `ADMIN_KEY` and `ADMIN_CERT` in `setup-kubectl.sh`.
  * Run `./util/setup-kubectl.sh`.

## Verify your setup
* Launch a HTTP proxy to access Kubernetes API
    * `kubectl proxy`
* View all workloads by browsing to `http://localhost:8001/ui`

## Install Helm
* Refer to [Quickstart Guide](https://github.com/kubernetes/helm/blob/master/docs/quickstart.md)

## Build and push your ELK docker images to container registry
* Get the credential of registry you created previously e.g. `elkacr.azurecr.io`:
    * `az acr credential show --name <acr_name> --resource-group <resource_group>`
* Replace registry_server, registry_username, registry_password in `push-images.sh` and run it.

## Deploy ELK cluster
* Go to `helm-charts` and modify `start-elk.sh` to replace placeholders with password and email.
* Run `./start-elk.sh`
* Browse to `http://localhost:8001/ui` to monitor the status of deployments.
* Run `kubectl get svc --namespace elk-cluster-ns` and get the public endpoint of Kibana service and access it from browser.

## Deploy filebeat to collect Kubernetes cluster logs for visualization in Kibana.
* Run `helm install filebeat`
* Go to Kibana service in browser and create index pattern.
* Go to Discover in the left pane to find log streams.

## Auto scaling
* Kubernetes supports horizontal pod autoscaler with `kubectl autoscale`. For example, auto scale a deployment with the number of pods between 2 and 5, target CPU utilization 80%. Run `kubectl autoscale deployment <deployment_name> --min=2 --max=5 --cpu-percent=80`.
* Currently, auto scaling of agent nodes in cluster in Azure Container Service is not supported. To manually change the number of agent nodes, run the command `az acs scale -g <resource_group> -n <cluster_name> --new-agent-count <number>`.
* Kubernetes cluster created with [acs-engine](https://github.com/Azure/acs-engine) in Azure supports auto scaling. [acs-engine-autoscaler](https://github.com/kubernetes/charts/tree/master/stable/acs-engine-autoscaler) is the package that deploys auto-scaler pod in the cluster.
  * Update `resourcegroup`, `azurespappid`, `azurespsecret`, `azuresptenantid`, `kubeconfigprivatekey`, `clientprivatekey` and `acsdeployment` in `helm-charts/acs-engine-autoscaler/values.yaml`.
  * Run `helm install helm-charts/acs-engine-autoscaler/`.

## Delete your Helm releases
* Run `helm list | awk '$1!="NAME" { print $1 }' | xargs helm delete` to delete all your Helm releases
Note: the command will delete All your existing Helm releases.