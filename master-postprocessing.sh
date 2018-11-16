#!/bin/sh

# Source: http://kubernetes.io/docs/getting-started-guides/kubeadm/

sudo mkdir /datahub
sudo unzip -n /vagrant/DHFOUNDATION*.ZIP -d /datahub
sudo chmod 755 -R /datahub
sudo chown vagrant:vagrant -R /datahub

datahubdir=$(ls -d /datahub/SAPDataHub*)

ln -s $datahubdir /datahub/SAPDataHub 

# Add the public key from node2 as authorized ssh client
cat /vagrant/shared/id_rsa.pub >> /home/vagrant/authorized_keys

# Modify installation files so it can be deployed on-premise
#sed -i 's/chmod -R a+rwx \/hana\/mounts &&//' /datahub/SAPDataHub/deployment/helm/hana/templates/hana-statefulset.yaml
sed -i 's/20Gi/19Gi/' /datahub/SAPDataHub/deployment/helm/hana/values.yaml
sed -i 's/terminationGracePeriodSeconds: 300/terminationGracePeriodSeconds: 1800/' /datahub/SAPDataHub/deployment/helm/vora-cluster/values.yaml
#sed -i 's/dbSpaceSize: 10000/dbSpaceSize: 5000/' /datahub/SAPDataHub/deployment/helm/vora-cluster/values.yaml
sed -i 's/replicationFactor: 2/replicationFactor: 1/' /datahub/SAPDataHub/deployment/helm/vora-cluster/values.yaml
#sed -i 's/storageSize: 50Gi/storageSize: 5Gi/' /datahub/SAPDataHub/deployment/helm/vora-cluster/values.yaml

nohup kubectl proxy --address=0.0.0.0 --port=8001 --accept-hosts='^*$' &

sleep 10

#for filename in /vagrant/*PersistantVolume.yaml; do
#  kubectl delete -f $filename
#  kubectl apply -f $filename
#done

exit
