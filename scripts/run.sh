#!/usr/bin/env bash

set -e

while getopts ':d:l:u:p:k:r:a:b:s:c:d:' arg
do
     case ${arg} in
        d) masterDns=${OPTARG};;
        l) resourceLocation=${OPTARG};;
        u) masterUsername=${OPTARG};;
        p) masterPassword=${OPTARG};;
        k) privateKey=${OPTARG};;
        r) registryUrl=${OPTARG};;
        a) registryUsername=${OPTARG};;
        b) registryPassword=${OPTARG};;
        s) storageAccount=${OPTARG};;
        c) storageAccountSku=${OPTARG};;
        d) repositoryUrl=${OPTARG};;
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


privateKeyFile='private_key'

masterUrl=${masterDns}.${resourceLocation}.cloudapp.azure.com

export KUBECONFIG=/root/.kube/config

# prerequisites, e.g. docker, nginx
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
apt-cache policy docker-ce
sudo apt-get install -y unzip docker-ce nginx apache2-utils

# install kubectl
cd /tmp
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# write private key
echo "${privateKey}" | base64 -d | tee ${privateKeyFile}
chmod 400 ${privateKeyFile}

mkdir -p /root/.kube
scp -o StrictHostKeyChecking=no -i ${privateKeyFile} ${masterUsername}@${masterUrl}:.kube/config ${KUBECONFIG}
kubectl get nodes

# install helm
curl -s https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
helm init

# download templates
curl -L ${repositoryUrl} -o template.zip
unzip -o template.zip -d template

# expose kubectl proxy
cd template/elk-acs-kubernetes-rc/
echo ${masterPassword} | htpasswd -c -i /etc/nginx/.htpasswd ${masterUsername}
cp config/nginx-site.conf /etc/nginx/sites-available/default
nohup kubectl proxy --port=8080 &
systemctl reload nginx

# push image
cd docker
if [ -z ${registryUrl} ]; then
    # assume azure container registry, image push is required.
    registryUrl=${registryUsername}.azurecr.io
    bash push-images.sh -r ${registryUrl} -u ${registryUsername} -p ${registryPassword}
fi

# install helm charts
cd ../helm-charts
bash start-elk.sh -r ${registryUrl} -u ${registryUsername} -p ${registryPassword} -d ${storageAccount} -l ${resourceLocation} -s ${storageAccountSku}
