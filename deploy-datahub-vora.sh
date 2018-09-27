#!/bin/sh

i=0
while [ $i -lt 30 ]; do
  echo "Waiting for kubernetes cluster to be up"
  masterok=$(kubectl get node master | grep Ready)
  node1ok=$(kubectl get node node1 | grep Ready)
  node2ok=$(kubectl get node node2 | grep Ready)
  if [ "$masterok" != "" ] && [ "$node1ok" != "" ] && [ "$node2ok" != "" ]
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
  voradir=$(ls -d /datahub/SAPV*Runtime) 
  echo "Vora: Assing nodes"
  $voradir/install.sh --assign-nodes --namespace=vora --docker-registry=10.11.12.10:5000
  sleep 10
  echo "Vora: Deploy environment" 
  $voradir/install.sh --namespace=vora --docker-registry=10.11.12.10:5000 -a --vora-admin-username=vora --vora-admin-password=cubisvora --provision-persistent-volumes=yes --nfs-address=master --nfs-path=/mnt/voranfs --local-nfs-path=/mnt/share --cert-domain=master -dt=onpremise --vsolution-import-path=/datahub/bdh-assembly-vsystem --interactive-security-configuration=no -ss=vora-diagnostic
  # Get vora-tx-coordinator port
  port=$(kubectl get services -n vora vora-tx-coordinator | grep -o -P '(?<=10002:).*(?=/TCP)')
  echo $port > /vagrant/shared/txcoordinatorport.txt
  echo "vora-tx-coordinator port is $port"
else
  echo "Kubernetes cluster up: Time out !"
fi

exit

