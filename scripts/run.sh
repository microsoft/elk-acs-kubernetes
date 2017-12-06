#!/usr/bin/env bash

log()
{
    echo "$1" | tee -a /tmp/output.log
}

set -e

echo $@

log "enter scripts/run.sh"
while getopts ':d:l:u:p:k:r:a:b:j:q:m:n:o:v:s:c:e:f:g:h:i:t:w:x:y:z:R:' arg; do
     log "arg $arg set with value ${OPTARG}"
     case ${arg} in
        d) masterDns=${OPTARG};;
        l) resourceLocation=${OPTARG};;
        u) masterUsername=${OPTARG};;
        p) masterPassword=${OPTARG};;
        k) privateKey=${OPTARG};;
        r) registryUrl=${OPTARG};;
        a) registryUsername=${OPTARG};;
        b) registryPassword=${OPTARG};;
        j) diagEvtHubNs=${OPTARG};;  # for logstash eh plugin
        q) diagEvtHubNa=${OPTARG};;  # for logstash eh plugin
        m) diagEvtHubKey=${OPTARG};;  # for logstash eh plugin
        n) diagEvtHubEntPa=${OPTARG};;  # for logstash eh plugin
        o) diagEvtHubPartNum=${OPTARG};;  # for logstash eh plugin
        v) diagEvtHubThreadWait=${OPTARG};;  # for logstash eh plugin
        s) storageAccount=${OPTARG};;
        c) storageAccountSku=${OPTARG};;
        e) repositoryUrl=${OPTARG};;
        f) directoryName=${OPTARG};;
        g) authenticationMode=${OPTARG};; # "AzureAD" or "BasicAuth"
        h) clientId=${OPTARG};;
        i) clientSecret=${OPTARG};;
        t) tenant=${OPTARG};;
        w) azureCliendId=${OPTARG};;
        x) azurePwd=${OPTARG};;
        y) azureTenant=${OPTARG};;
        z) subscriptionId=${OPTARG};;
        R) resourceGroup=${OPTARG};;
     esac
done

if [ -z ${masterDns} ]; then
    echo 'Master DNS is required' >&2
    exit 1
fi

if [ -z ${resourceLocation} ]; then
    echo 'Resource location is required' >&2
    exit 1
fi

if [ -z ${masterUsername} ]; then
    echo 'Master username is required' >&2
    exit 1
fi

if [ -z ${masterPassword} ]; then
    echo 'Master password is required' >&2
    exit 1
fi

if [ -z ${privateKey} ]; then
    echo 'Private key is required' >&2
    exit 1
fi

if [ -z ${storageAccount} ]; then
    echo 'Storage account name is required' >&2
    exit 1
fi

if [ -z ${storageAccountSku} ]; then
    echo 'Storage account sku is required' >&2
    exit 1
fi

if [ -z ${repositoryUrl} ]; then
    echo 'Repository URL is required' >&2
    exit 1
fi

if [ -z ${azureCliendId} ]; then
    echo 'Azure AD client id is required' >&2
    exit 1
fi

if [ -z ${azurePwd} ]; then
    echo 'Azure AD password is required' >&2
    exit 1
fi

if [ -z ${azureTenant} ]; then
    echo 'Azure AD tenand id is required' >&2
    exit 1
fi

if [ -z ${authenticationMode} ]; then
    authenticationMode = 'BasicAuth'
fi

if [ "${authenticationMode}" = "AzureAD" ]; then
    if [ -z ${clientId} ]; then
        echo 'Client ID is required in Azure AD mode' >&2
        exit 1
    fi
    if [ -z ${clientSecret} ]; then
        echo 'Client secret is required in Azure AD mode' >&2
        exit 1
    fi
    if [ -z ${tenant} ]; then
        echo 'Tenant is required in Azure AD mode' >&2
        exit 1
    fi
fi

privateKeyFile='private_key'

masterUrl=${masterDns}.${resourceLocation}.cloudapp.azure.com
log "masterUrl: ${masterUrl}"

export KUBECONFIG=/root/.kube/config
export HOME=/root

# prerequisites, e.g. docker, openresty
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 52E16F86FEE04B979B07E28DB02C46DF417A0893
sudo apt-get -y install apt-transport-https

sudo apt-get -y install software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
wget -qO - https://openresty.org/package/pubkey.gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo add-apt-repository -y "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main"
sudo apt-get update
apt-cache policy docker-ce
sudo apt-get install -y unzip docker-ce openresty apache2-utils azure-cli

log "Login azure cli"
az login --service-principal -u ${azureCliendId} -p ${azurePwd} -t ${azureTenant}
az account set -s ${subscriptionId}

# Add NSG rule
# virtualNetwork:22 to Any:*
nsg=$(az network nsg list -g ${resourceGroup} --output table | grep -o -e 'k8s-master-.*-nsg')
az network nsg rule create -n ssh --nsg-name ${nsg} --priority 102 -g ${resourceGroup} --protocol TCP --destination-port-range 22 --source-address-prefix VirtualNetwork



log "install kubectl"
# install kubectl
az acs kubernetes install-cli
# cd /tmp
# # curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
# # ACS currently support K8s v1.7.7
# curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.7.7/bin/linux/amd64/kubectl
# chmod +x ./kubectl
# sudo mv ./kubectl /usr/local/bin/kubectl


log "write private key to ${privateKeyFile}"
# write private key
echo "${privateKey}" | base64 -d | tee ${privateKeyFile}
chmod 400 ${privateKeyFile}
mv ${privateKey} ~/.ssh/id_rsa
az acs kubernetes get-credentials
# log "copy ${masterUsername}@${masterUrl}:.kube/config to ${KUBECONFIG}"
# mkdir -p /root/.kube
# scp -o StrictHostKeyChecking=no -i ${privateKeyFile} ${masterUsername}@${masterUrl}:.kube/config ${KUBECONFIG}
kubectl get nodes

log "install helm"
# install helm
curl -L "https://kubernetes-helm.storage.googleapis.com/helm-v2.5.1-linux-amd64.tar.gz" -o helm.tar.gz
tar vzxf helm.tar.gz
cp linux-amd64/helm /usr/local/bin/helm
helm init

# make sure helm installed
until [ $(kubectl get pods -n kube-system -l app=helm,name=tiller -o jsonpath="{.items[0].status.containerStatuses[0].ready}") = "true" ]; do
    sleep 2
done

log "download templates from ${repositoryUrl}"
# download templates
curl -L ${repositoryUrl} -o template.zip
unzip -o template.zip -d template

log "expose kubectl proxy at 8080"
# expose kubectl proxy
nohup kubectl proxy --port=8080 &

log "config nginx for ${authenticationMode} authentication mode"
cd template/${directoryName}
if [ "${authenticationMode}" = "BasicAuth" ]; then
    echo ${masterPassword} | htpasswd -c -i /usr/local/openresty/nginx/conf/.htpasswd ${masterUsername}
    cp config/nginx-basic.conf /usr/local/openresty/nginx/conf/nginx.conf
    systemctl reload openresty
else
    opm get pintsized/lua-resty-http bungle/lua-resty-session
    cp config/openidc.lua /usr/local/openresty/lualib/resty/openidc.lua
    export TENANT=${tenant}
    export CLIENT_ID=${clientId}
    export CLIENT_SECRET=${clientSecret}
    cat config/nginx-openid.conf | envsubst > /usr/local/openresty/nginx/conf/nginx.conf
    systemctl reload openresty
fi

# push image
cd docker
if [ -z ${registryUrl} ]; then
    log "push image to azure container registry: ${registryUsername}.azurecr.io"
    # assume azure container registry, image push is required.
    registryUrl=${registryUsername}.azurecr.io
    bash push-images.sh -r ${registryUrl} -u ${registryUsername} -p ${registryPassword} -a ${diagEvtHubNs} -b ${diagEvtHubNa} -c ${diagEvtHubKey} -d ${diagEvtHubEntPa} -e ${diagEvtHubPartNum} -f ${diagEvtHubThreadWait}

    cd ../helm-charts
    bash start-elk.sh -r ${registryUrl} -u ${registryUsername} -p ${registryPassword} -d ${storageAccount} -l ${resourceLocation} -s ${storageAccountSku} -a ${masterUsername} -b ${masterPassword}

else
    log "install helm charts and start elk cluster"
    # install helm charts
    cd ../helm-charts
    bash start-elk.sh -r ${registryUrl} -d ${storageAccount} -l ${resourceLocation} -s ${storageAccountSku} -a ${masterUsername} -b ${masterPassword}

fi
log "exit scripts/run.sh"
log "==================="
log " "
log "Re-deploy solution using Azure Container Registry:"
log "run.sh -d ${masterDns} -l ${resourceLocation} -u ${masterUsername} -p ${masterPassword} -k ${privateKey} -a ${registryUsername} -b ${registryPassword} -j ${diagEvtHubNs} -q ${diagEvtHubNa} -m ${diagEvtHubKey} -n ${diagEvtHubEntPa} -o ${diagEvtHubPartNum} -v ${diagEvtHubThreadWait} -s ${storageAccount} -c ${storageAccountSku} -e ${repositoryUrl} -f ${directoryName} -g ${authenticationMode} -h ${clientId} -i ${clientSecret} -t ${tenant}"
log " "
log "Re-deploy solution using Custom Registry:"
log "run.sh -d ${masterDns} -l ${resourceLocation} -u ${masterUsername} -p ${masterPassword} -k ${privateKey} -r ${registryUrl} -j ${diagEvtHubNs} -q ${diagEvtHubNa} -m ${diagEvtHubKey} -n ${diagEvtHubEntPa} -o ${diagEvtHubPartNum} -v ${diagEvtHubThreadWait} -s ${storageAccount} -c ${storageAccountSku} -e ${repositoryUrl} -f ${directoryName} -g ${authenticationMode} -h ${clientId} -i ${clientSecret} -t ${tenant}"
log " "
log "==================="
exit 0
