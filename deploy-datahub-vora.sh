#!/bin/bash

i=0
while [ $i -lt 30 ]; do
  echo "Waiting for kubernetes cluster to be up"
  masterok=$(kubectl get node master | grep Ready)
  node1ok=$(kubectl get node node1 | grep Ready)
  node2ok=$(kubectl get node node2 | grep Ready)
  node3ok=$(kubectl get node node2 | grep Ready)
  if [ "$masterok" != "" ] && [ "$node1ok" != "" ] && [ "$node2ok" != "" ] && [ "$node3ok" != "" ]
  then 
    i=99
  else
    i=$((i+1))
    sleep 30
  fi
done
if [ $i -eq 99 ]
then
  echo "Kubernetes cluster is up!"
  echo "Running as $(whoami)"

# Credential informations should be provided in the sourced shell script
  source /vagrant/credential.sh
  /datahub/SAPDataHub/install.sh --namespace=vora --registry=10.11.12.10:5000 --sap-registry-login-type=2 --sap-registry-login-username=$SUSER --sap-registry-login-password='$SUSERPW' -a --cert-domain=master --vora-admin-username=$DATAHUBUSER --vora-admin-password='$DATAHUBPW' --vora-system-password='$DATAHUBPW' --vsystem-tenant=cubis --interactive-security-configuration=no --enable-checkpoint-store=yes --checkpoint-store-type=webhdfs --checkpoint-store-connection=webhdfs://10.11.12.11:50070/user/vora/checkpoint-store/ -ss=vora-diagnostic --pv-storage-class=rook-ceph-block --non-interactive-mode --validate-checkpoint-store=no -c
  sleep 10
  echo "Vora: Deploy environment" 
else
  echo "Kubernetes cluster up: Time out !"
fi

exit

