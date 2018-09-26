#!/bin/sh

# Source: http://kubernetes.io/docs/getting-started-guides/kubeadm/

sudo mkdir /datahub
sudo unzip -o /vagrant/DATAHUBRT.ZIP -d /datahub
sudo unzip -o /vagrant/DHFLOWAGENT.ZIP -d /datahub
sudo chmod 755 -R /datahub
sudo chown vagrant:vagrant -R /datahub

# Add the public key from node2 as authorized ssh client
cat /vagrant/shared/id_rsa.pub >> /home/vagrant/authorized_keys

# prevent installation from failing because of unavailable gpg server
sed -i -e 's/.*gpg/#&/' /datahub/SAPVora-2.2.48-DistributedRuntime/images/consul/Dockerfile

cd /datahub/bdh-assembly-vsystem
./prepare.sh
cd $HOME

sed -i 's/replicationFactor: 2/replicationFactor: 1/' /datahub/SAPVora-2.2.48-DistributedRuntime/deployment/helm/vora-cluster/values.yaml

nohup kubectl proxy --address=10.11.12.10 --port=8001 --accept-hosts='^*$' &

sleep 10

exit
