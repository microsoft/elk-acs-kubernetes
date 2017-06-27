#!/bin/bash
#
# setup kubectl

MASTER_HOST=<dnsPrefix>.<location>.cloudapp.azure.com
CA_CERT=<path-to-ca.crt>
ADMIN_KEY=<path-to-kubectlClient.key>
ADMIN_CERT=<path-to-kubectlClient.crt>
kubectl config set-cluster default-cluster --server=https://${MASTER_HOST} --certificate-authority=${CA_CERT}
kubectl config set-credentials default-admin --certificate-authority=${CA_CERT} --client-key=${ADMIN_KEY} --client-certificate=${ADMIN_CERT}
kubectl config set-context default-system --cluster=default-cluster --user=default-admin
kubectl config use-context default-system
kubectl get nodes