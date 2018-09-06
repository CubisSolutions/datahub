#!/bin/sh

# Source: http://kubernetes.io/docs/getting-started-guides/kubeadm/

sudo mkdir /datahub
sudo unzip /vagrant/DATAHUBRT.ZIP -d /datahub
sudo unzip /vagrant/DHFLOWAGENT.ZIP -d /datahub
sudo chmod 755 -R /datahub
sudo chown vagrant:vagrant -R /datahub

# prevent installation from failing because of unavailable gpg server
sed -i -e 's/.*gpg/#&/' /datahub/SAPVora-2.2.48-DistributedRuntime/images/consul/Dockerfile

cd /datahub/bdh-assembly-vsystem
./prepare.sh
cd $HOME

sed -i 's/replicationFactor: 2/replicationFactor: 1/' /datahub/SAPVora-2.2.48-DistributedRuntime/deployment/helm/vora-cluster/values.yaml

sudo su - hadoop -c 'ssh-keyscan localhost,0.0.0.0 > ~/.ssh/known_hosts'
sudo su - hadoop -c 'hdfs namenode -format'
sudo su - hadoop -c '$HADOOP_HOME/sbin/start-dfs.sh'
sudo su - hadoop -c '$HADOOP_HOME/sbin/start-yarn.sh'

nohup kubectl proxy --address=10.11.12.10 --port=8001 --accept-hosts='^*$' &

sleep 10

exit
