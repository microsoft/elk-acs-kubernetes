# Deploy ELK on Kubernetes in Azure Container Service (ACS)

This repository contains tools and helm charts to help deploy the [ELK stack](https://www.elastic.co/products) on [Kubernetes](https://kubernetes.io/) in [Azure Container Service (ACS)](https://docs.microsoft.com/azure/container-service/).

## Elastic Stack on Kubernetes Architecture
![Elastic Stack on Kubernetes Architecture](/elk-acs-kube-arch.png)

## Prerequesites

* An Azure subscription. If you do not have an Azure subscription, you can sign up for a [Azure Free Trial Subscription](https://azure.microsoft.com/offers/ms-azr-0044p/)

* Login to your [Azure portal](https://portal.azure.com).

## Instructions
1. Go to Azure Marketplace and find `Elastic Stack on Kubernetes` solution template and click `Create`.

1. In `Basics` panel, `Controller Username` and `Controller Password` need to be valid Ubuntu credential and will be used to access Kibana.
   > Password must be at least 12 characters long and contain at least one lower case, upper case, digit and special character. 
   
   > `Resource Group` should be a new or an empty one to create your Kubernetes.

   > Note: not all VM sizes are supported across all regions. You can check it at [Azure products available by region](https://azure.microsoft.com/en-us/regions/services/)

1. In `Common Settings` panel, provide the following:
   * `Dns prefix` - The DNS name prefix of your Kubernetes controller. You can access the Kubernetes dashboard at [http://\<dns-prefix>control.\<resource-location>.cloudapp.azure.com](#)
     > DNS prefix and resource location pair should be global unique.
   <!-- * `Dns prefix` - e.g. "contoso12345"
     * Create an app in Azure Active Directory. Go to `Azure Active Directory` -> `App registrations` -> `New application registration`. Provide the following:
       * `Name` - e.g. "contoso12345app"
       * `Application Type` - Web app / API
       * `Sign-on URL` - it's to be: http://<`Dns prefix`>control.<`Location`>.cloudapp.azure.com. e.g. http://contoso12345control.eastus.cloudapp.azure.com
     * Go to `Settings` -> `API ACCESS` -> `Required permissions` and tick `Access the directory as the signed-in user`, `Read all users' basic profiles` and `Sign in and read user profile` and click `Grant Permissions`. -->
   * `Registry url`- If using public registry e.g. Docker Hub. The solution will automatically create an Azure Container Registry to host image if it is empty.
   * `Event hub namespace` - e.g. "myeventhub".
   * `Event hub key name` - event hub `SETTINGS` find `Shared access policies` e.g. "RootManageSharedAccessKey".
   * `Event hub key value` - SAS policy key value.
   * `List of event hubs` - event hub `ENTITIES` find `Event Hubs` list the event hubs from which you'd pull events e.g. "insights-logs-networksecuritygroupevent,insights-logs-networksecuritygrouprulecounter".
   * `Event hub partition count` - partition count of event hubs (all listed event hubs must have the same partition count).
   * `Thread wait interval(s)` - logstash event hub plugin thread wait interval in seconds.
   * `Data node storage account sku` - storage account sku used by Elasticsearch data node.
   * `Authentication Mode` - authentication mode for accessing Kubernetes dashboard.
      * `Basic Authentication` mode uses `Controller Username` and `Controller Password`.
      * `Azure Active Directory` mode uses Azure AD service principal for authentication. You need to provide your service principal information:
        
        > Follow [Azure Service Principal using Azure portal](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal) to create an Azure Service Principal and add access to your subscription. The `Sign-on URL` should be [http://\<dns-prefix>control.\<resource-location>.cloudapp.azure.com]().
        
        > To grand your Service Principal access: Go to your `Service princial`-> `Settings` ->  `Required permissions`, tick `Access the directory as the signed-in user`, `Read all users' basic profiles` and `Sign in and read user profile`, then save it, then click `Grant Permissions`
        * `Azure AD client ID` - [Application ID](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal#get-application-id-and-authentication-key)
        * `Azure AD client secret` - [Your generated key](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal#get-application-id-and-authentication-key)
        * `Azure AD tenant` - [Tenant ID](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal#get-tenant-id)

1. In `Kubernetes Cluster Settings` panel, provide the following:
     * `Agent Count` - number of agent nodes of Kubernetes cluster
     * `Agent Node Size`
     * `Master Count` - number of masters of Kubernetes cluster

1. In `Security Settings` panel, provide the following:
     * `SSH public key` - ssh public key for controller node to talk to Kubernetes cluster
     * `Base64 encoded SSH private key` - base64 encoded ssh private key
     * `Service principal client ID` - "Application ID" of Service Principal created in previous step.
     * `Service principal client secret` - "Your generated key" of Service Principal created in previous step.

     > You can generate the SSH public key/private key pair using [js-keygen](https://microsoft.github.io/elk-acs-kubernetes/)

1. Click OK in Summary panel and create the solution.

> The creation may cost half an hour.

## Acccess your ELK on Kubernetes
After the deployment succeeds, you can find the Kubernetes dashboard and kibana/elasticsearch/logstash endpoints
* You can access your kubernetes dashboar at:  
  [http://\<dns-prefix>control.\<resource-location>.cloudapp.azure.com/api/v1/proxy/namespaces/kube-system/services/kubernetes-dashboard/#!/overview?namespace=elk-cluster-ns]()

* Find kibana/elasticsearch/logstash endpoints at `Discovery and Load Balancing` -> `Services` on your Kubernetes dashboard.

* To view events from event hubs, go to kibana portal -> `Management` -> `Configure an index pattern` -> input `wad` in `Index name or pattern` textbox -> click Create.

## Troubleshooting
* For resource deployment failure, you can find more information from Azure Portal.
* For solution template failure, you can extract logs by ssh to `controllervm`. Deployment log is at `/tmp/outputl.log`.

## License
  This project is under MIT license.

  `config/openidc.lua` is derived from [https://github.com/pingidentity/lua-resty-openidc](https://github.com/pingidentity/lua-resty-openidc) with some modifications to satisfy requirements and this file (`config/openidc.lua`) is under Apache 2.0 license.
