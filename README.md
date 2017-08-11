# Deploy ELK on Kubernetes in Azure Container Service (ACS)

This repository contains tools and helm charts to help deploy the [ELK stack](https://www.elastic.co/products) on [Kubernetes](https://kubernetes.io/) in [Azure Container Service (ACS)](https://docs.microsoft.com/azure/container-service/).

## Prerequesites

* An Azure subscription. If you do not have an Azure subscription, you can sign up for a [Azure Free Trial Subscription](https://azure.microsoft.com/offers/ms-azr-0044p/)

* Install the Azure Command Line Interface (CLI) by following the instructions in the [Install Azure CLI 2.0](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) article.

## Instructions

* Create an [Azure Service Principal](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?toc=%2fazure%2fazure-resource-manager%2ftoc.json):
   ```shell
   az ad sp create-for-rbac
   ```
* Replace `servicePrincipalClientId` with `appId` and `servicePrincipalClientSecret` with `password` in `param.json`.
* Input value for `linuxAdminUsername` and `adminPassword`.
* [Generate a SSH key pair](https://wiki.osuosl.org/howtos/ssh_key_tutorial.html) and update `sshRSAPublicKey` and `privateKey`. The `privateKey` needs to be [base64 encoded](https://en.wikipedia.org/wiki/Base64).
* Create a new resource group and start your deployment by running the following:
   ```shell
   az group deployment create --verbose --resource-group <resource-group-name> --template-file ARM-template\mainTemplate.json --parameters @ARM-template\param.json
   ```
* It could take up to 30 minutes for the deployment to finish. After deployment succeeds, grab the controller endpoint from the output to access [Kubernetes dashboard UI](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/). i.e. `acs-dns-abcdefcontrol.westus.cloudapp.azure.com/ui`
   ```shell
   ...
   "outputs": {
     "agentFQDN": {
       "type": "String",
       "value": ""
     },
     "hostname": {
       "type": "String",
       "value": "acs-dns-abcdefcontrol.westus.cloudapp.azure.com"
     },
    ...
   ```

## License
  This project is under MIT license.

  ```config/openidc.lua``` is derived from [https://github.com/pingidentity/lua-resty-openidc](https://github.com/pingidentity/lua-resty-openidc) with some modifications to satisfy requirements and this file (```config/openidc.lua```) is under Apache 2.0 license.
  