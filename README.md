# Deploy ELK on Kubernetes in Azure Container Service (ACS)

This repository contains tools and helm charts to help deploy the [ELK stack](https://www.elastic.co/products) on [Kubernetes](https://kubernetes.io/) in [Azure Container Service (ACS)](https://docs.microsoft.com/azure/container-service/).

## Prerequesites

* An Azure subscription. If you do not have an Azure subscription, you can sign up for a [Azure Free Trial Subscription](https://azure.microsoft.com/offers/ms-azr-0044p/)

* Install the Azure Command Line Interface (CLI) by following the instructions in the [Install Azure CLI 2.0](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) article.

## Elastic Stack on Kubernetes Architecture
![Elastic Stack on Kubernetes Architecture](/elk-acs-kube-arch.png)


## Instructions
* Go to Azure Marketplace and find `Elastic Stack on Kubernetes` solution template and click `Create`
* In `Basics` panel, `Controller Username` and `Controller Password` need to be valid Ubuntu credential and will be used to access Kibana. `Resource Group` should be new or empty. Note: not all VM sizes are supported across all regions.
* In `Common Settings` panel, provide the following:
   * `Dns prefix` - e.g. "contoso12345".
     * Create an app in Azure Active Directory. Go to `Azure Active Directory` -> `App registrations` -> `New application registration`. Provide the following:
       * `Name` - e.g. "contoso12345app"
       * `Application Type` - Web app / API
       * `Sign-on URL` - it's to be: http://<`Dns prefix`>control.<`Location`>.cloudapp.azure.com. e.g. http://contoso12345control.eastus.cloudapp.azure.com
     * Go to `Settings` -> `API ACCESS` -> `Required permissions` and tick `Access the directory as the signed-in user`, `Read all users' basic profiles` and `Sign in and read user profile` and click `Grant Permissions`.
   * `Registry url`- if using public registry e.g. Docker Hub.
   * `Event hub namespace` - e.g. "myeventhub".
   * `Event hub key name` - event hub `SETTINGS` find `Shared access policies` e.g. "RootManageSharedAccessKey".
   * `Event hub key value` - SAS policy key value.
   * `List of event hubs` - event hub `ENTITIES` find `Event Hubs` list the event hubs from which you'd pull events e.g. "insights-logs-networksecuritygroupevent,insights-logs-networksecuritygrouprulecounter".
   * `Event hub partition count` - partition count of event hubs (all listed event hubs must have the same partition count).
   * `Thread wait interval(s)` - logstash event hub plugin thread wait interval in seconds.
   * `Data node storage account sku` - storage account sku used by Elasticsearch data node.
   * `Authentication Mode` - authentication mode for accessing Kubernetes dashboard. `Basic Authentication` mode uses `Controller Username` and `Controller Password`. `Azure Active Directory` mode uses Azure AD service principal for authentication. You need to:
     * Create an [Azure Service Principal](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?toc=%2fazure%2fazure-resource-manager%2ftoc.json):
       ```shell
       az account show
       az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
       ```
     * "appId" is `Azure AD client ID`
     * "password" is `Azure AD client secret`
     * "tenant" is `Azure AD tenant`
* In `Kubernetes Cluster Settings` panel, provide the following:
     * `Agent Count` - number of agent nodes of Kubernetes cluster
     * `Agent Node Size`
     * `Master Count` - number of masters of Kubernetes cluster
* In `Security Settings` panel, provide the following:
     * `SSH public key` - ssh public key for controller node to talk to Kubernetes cluster
     * `Base64 encoded SSH private key` - base64 encoded ssh private key
     * `Service principal client ID` - client ID of service principal for accessing Azure resources. Find it in AAD registered app -> `Application ID`.
     * `Service principal client secret` - client secret. Create one in AAD registered app -> `Settings` -> `Keys`.
* Click OK in Summary panel and create the solution.
* After the deployment succeeds, find the FQDN of `controllervm` in the resource group.
     * Kubernetes dashboard: http://<`Dns prefix`>control.<`Location`>.cloudapp.azure.com/api/v1/proxy/namespaces/kube-system/services/kubernetes-dashboard/. The namespace of your kubernetes cluster is `elk-cluster-ns`.
     * Find kibana/elasticsearch/logstash endpoints at `Discovery and Load Balancing` -> `Services`. To view events from event hubs, go to kibana portal -> `Management` -> `Configure an index pattern` -> input `wad` in `Index name or pattern` textbox -> click Create.

## Troubleshooting
* For resource deployment failure, you can find more information from Azure Portal.
* For solution template failure, you can extract logs by ssh to `controllervm`. Deployment log is at `/tmp/outputl.log`.

## License
  This project is under MIT license.

  ```config/openidc.lua``` is derived from [https://github.com/pingidentity/lua-resty-openidc](https://github.com/pingidentity/lua-resty-openidc) with some modifications to satisfy requirements and this file (```config/openidc.lua```) is under Apache 2.0 license.
