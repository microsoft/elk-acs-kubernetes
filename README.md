# Deploy Elastic Stack on Kubernetes in Azure Container Service (ACS)

<!-- [![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://ms.portal.azure.com/#create/visualstudiochina.elk-on-kubepre-release) -->

> This repo is deprecated.

This repository contains tools and helm charts to help deploy the [Elastck stack](https://www.elastic.co/products) on [Kubernetes](https://kubernetes.io/) in [Azure Container Service (ACS)](https://docs.microsoft.com/azure/container-service/). You can now try this solution template in region: `East US`, `South Central US` and `West Europe`

## How the solution works

* Deploy a Kubernetes cluster on Azure.
* Deploy a Virtual Machine served as the Controller Node to manage and configure Kubernetes cluster on Azure.
* Register Controller Node's FQDN as the entry to Kubernetes dashbord.
* Authentication supported for Kubernetes dashbord:
    * Username / Password
    * [Azure Active Directory OAuth 2.0](https://docs.microsoft.com/en-us/azure/active-directory/develop/active-directory-protocols-oauth-code)
* Deploy a Azure Container Registry if no public registry is provided.
* Build docker images for Elastic Stack and push images to the Azure Container Register. If public registry that stores docker images for Elastic Stack is provided, this step is skipped.
* Install Elastic Stack defined as Helm Charts on Kubernetes.

## Elastic Stack on Kubernetes Architecture
![Elastic Stack on Kubernetes Architecture](image/elk-acs-kube-arch.png)

## Prerequesites

* An Azure subscription. If you do not have an Azure subscription, you can sign up for a [Azure Free Trial Subscription](https://azure.microsoft.com/offers/ms-azr-0044p/)

* Login to your [Azure portal](https://portal.azure.com).

## Instructions
1. <a id='create-sp'></a>Follow tutorial [Create Azure Service Principal using Azure portal](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal) to create an Azure Service Principal and assign it `Contributor` role access to your subscription.

    * Assign application a contributor role to your subscription. The subsciption is the one where you will deploy the Elastic Stack.
    > Note: `Application ID`, `Password` and `Tenant ID` will be used in later stages of the deployment.

1. Go to Azure Marketplace, find `Elastic Stack on Kubernetes` solution template and click `Create`.

1. In `Basics` panel, `Controller Username` and `Controller Password` need to be valid Ubuntu credential and will be used to access Kibana.
    > Password must be at least 12 characters long and contain at least one lower case, upper case, digit and special character.

    > `Resource Group` should be a new or an empty one to create your Kubernetes.

    > Note: Due to Azure Container Service - Kubernetes (AKS) in preview isn't available across all regions globally. Deployments in following regions have been verified: `East US`, `South Central US` and `West Europe`. More regions will be supported as AKS enters general availability. Not all **VM sizes** are supported across all regions. You can check product availabilities from [Azure products available by region](https://azure.microsoft.com/en-us/regions/services/)


1. In `Common Settings` panel, provide the following:
   * `Dns prefix` - The DNS name prefix of your Kubernetes controller. The `dns prefix` and region location will format your Kubernetes dashboard host name. So the `dns prefix` and `location` pair must be globally unique.

   * `Registry url`- The URL of a public registry that hosts `elasticsearch `, `kibana` and `logstash` docker images. If this field is empty, the solution will automatically create an Azure Container Registry instance.

    > In the following field, you need to enter your Azure Event Hub connect information. If you want the logstash to get logs from log shipper instead of Azure Event hub, keep the `Event hub namespace`/`key name`/`key value` as `undefined`.

    > The Event hub namespace, key name, key value and event hubs can format the event hub's connection string: `Endpoint=sb://<namespace>.servicebus.windows.net/;SharedAccessKeyName=<key-name>;SharedAccessKey=<key-value>;EntityPath=<eventhub-name>`. The key should be given access with `listen`.

   * `Event hub namespace` - e.g. "myeventhub".
   * `Event hub key name` - event hub `SETTINGS` find `Shared access policies` e.g. "RootManageSharedAccessKey".
   * `Event hub key value` - SAS policy key value.
   * `List of event hubs` - event hub `ENTITIES` find `Event Hubs` and list the event hubs from which you'd pull events e.g. "insights-logs-networksecuritygroupevent,insights-logs-networksecuritygrouprulecounter". Event hubs in the list must be existed and are comma seperated.

    > If you are pulling events out of various event hubs with different partition counts, you are advised to deploy multiple instances of the solution.

   * `Event hub partition count` - partition count of event hubs (all listed event hubs must have the same partition count).
   * `Thread wait interval(s)` - logstash event hub plugin thread wait interval in seconds.

   * `Data node storage account sku` - storage account sku used by Elasticsearch data node.
   * `Authentication Mode` - authentication mode for accessing Kubernetes dashboard.
      * `Basic Authentication` mode uses `Controller Username` and `Controller Password`.
      * <a id='aad-login'></a>`Azure Active Directory` mode uses Azure AD service principal for authentication. You need to provide your service principal information which you get at [Step 1](#create-sp):

        * `Azure AD client ID` - [Application ID](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal#get-application-id-and-authentication-key)
        * `Azure AD client secret` - [Your generated key](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal#get-application-id-and-authentication-key)
        * `Azure AD tenant` - [Tenant ID](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal#get-tenant-id)

1. In `Kubernetes Cluster Settings` panel, provide the following:
   * `Agent Count` - number of agent nodes of Kubernetes cluster
   * `Agent Node Size`
   * `Master Count` - number of masters of Kubernetes cluster

1. In `Security Settings` panel, provide the following:

   > You can generate the SSH public key/private key pair using [js-keygen](https://microsoft.github.io/elk-acs-kubernetes/)

   * `SSH public key` - ssh public key for controller node to talk to Kubernetes cluster
   * `Base64 encoded SSH private key` - base64 encoded ssh private key

   > The `Service principal client ID` and `Service principal client secret` are used to create and manage the Kubernetes cluster, they can be the client id and secret you get from [Step 1](#create-sp). Ensure the Service principal used here has contributor access to your subscription and in the same AAD tenant as your subscription.

   * `Service principal client ID` - Application ID
   * `Service principal client secret` - Your generated key


1. Click OK in Summary panel and create the solution.

   > The creation may cost around half an hour. You can continue the next step while the creation.

1. If you choose the AAD mode to login your Kubernetes dashboard in [step 4](#aad-login), You need to set the redirect information in Azure Service Principal you created in [step 1](#create-sp).

   1. Go to your Azure Service Principal: Click `Azure Active Directory` -> `App registrations`, search your Service Princial name and click it.

   1. Spell out your Kubernetes dashboard host name and note it as `<host-name>`. The format should be `http://<dns-prefix>control.<resource-location>.cloudapp.azure.com`.
      > Both `dns-prefix` and `resource-location` are set in `Basic Panel`.
      > `dns-prefix` is specified in `Basic Settings`, `resource-location` is the region where you deploy your Elastic Stack. Deployments in following regions have been verified: `East US`, `South Central US` and `West Europe`.

   1. Set the Sign-on URL: In the `Settings` page, click `Properties`, set the `Home page URL` to `<host-name>` you spelled out. Click `Save`.

   1. Set the redirect URL: In the `Settings` page, click `Reply URLs`, remove the exiting URL, add URL `<host-name>/callback`. Click `Save`.

       ![Add Azure Service Principal redirect URL](image/elk-acs-kube-aad-redirect.png)

   1. Grant your Service Principal permissions: In the `Settings` page, click `Required permissions` -> `Windows Azure Active Directory`, tick `Read all users' basic profiles` and `Sign in and read user profile`. Click `Save` in `Enable Access` pane then `Grant Permissions` in `Required permissions` pane. Click `Yes` to confirm the action.

      ![Add Azure Service Principal access](image/elk-acs-kube-aad-access.png)

## Acccess your Elastic Stack on Kubernetes

After the deployment succeeds, you can find the Kubernetes dashboard and kibana/elasticsearch/logstash endpoints
* You can access your Kubernetes dashboard at:
  [http://\<dns-prefix>control.\<resource-location>.cloudapp.azure.com/api/v1/proxy/namespaces/kube-system/services/kubernetes-dashboard/#!/overview?namespace=elk-cluster-ns](#)

  The namespace is `elk-cluster-ns`.

* Find kibana/logstash endpoints at `Discovery and Load Balancing` -> `Services` on your Kubernetes dashboard.

  > kibana dashboard's credential is the same as controller you specified in Basic Setting.

* To manage the Kubernetes cluster, you can use `kubectl` on controllervm.

  > The SSH credential is the same specified in Basic Setting.

## How the logs are consumed by your Elastic Stack

The solution supports two ways to ship logs to Elastic Stack:
* Ingest logs from event hub(s) by logstash input plugin for data from Event Hubs. You need to define index pattern **wad** in Kibana. [Index Patterns](https://www.elastic.co/guide/en/kibana/current/index-patterns.html). To learn more about [Logstash input plugin for data from Event Hubs](https://github.com/Azure/azure-diagnostics-tools/tree/master/Logstash/logstash-input-azureeventhub)
* Log shippers e.g. [Filebeat](https://www.elastic.co/products/beats/filebeat)

## Troubleshooting

* For resource deployment failure, you can find more information from Azure Portal.
* For solution template failure, you can extract logs by ssh to `controllervm`. Deployment log is at `/tmp/output.log`.

## Related

* [Access kubernetes using web UI (dashboard)](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
* [Manage Kubernetes using kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
* [Scale agent nodes in a Container Service cluster](https://docs.microsoft.com/en-us/azure/container-service/dcos-swarm/container-service-scale)
* [Communication between Kubernetes master and node](https://kubernetes.io/docs/concepts/architecture/master-node-communication/)
* [Ship log to logstash using log shipper filebeat](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-getting-started.html)
* [Azure Event Hubs](https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-features)
* [Stream Azure Diagnostic Logs to an Event Hubs Namespace](https://docs.microsoft.com/en-us/azure/monitoring-and-diagnostics/monitoring-stream-diagnostic-logs-to-event-hubs)

## License

  This project is under MIT license.

  `config/openidc.lua` is derived from [https://github.com/pingidentity/lua-resty-openidc](https://github.com/pingidentity/lua-resty-openidc) with some modifications to satisfy requirements and this file (`config/openidc.lua`) is under Apache 2.0 license.

# Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
