#!/bin/sh

# Source: http://kubernetes.io/docs/getting-started-guides/kubeadm/

sudo mkdir /datahub
sudo unzip -o /vagrant/DATAHUBRT.ZIP -d /datahub
sudo unzip -o /vagrant/DHFLOWAGENT.ZIP -d /datahub
sudo unzip -o /vagrant/DHSPARKINT.ZIP -d /datahub
sudo chmod 755 -R /datahub
sudo chown vagrant:vagrant -R /datahub

# Prepare for spark integration
sudo mkdir /opt/vora-spark
sudo tar -xvf /datahub/SAPVora-SparkIntegration/vora-spark.tar.gz -C /opt/vora-spark

# Add the public key from node2 as authorized ssh client
cat /vagrant/shared/id_rsa.pub >> /home/vagrant/authorized_keys

# prevent installation from failing because of unavailable gpg server
sed -i -e 's/.*gpg/#&/' /datahub/SAPVora-2.2.48-DistributedRuntime/images/consul/Dockerfile

cd /datahub/bdh-assembly-vsystem
./prepare.sh
cd $HOME

sed -i 's/replicationFactor: 2/replicationFactor: 1/' /datahub/SAPVora-2.2.48-DistributedRuntime/deployment/helm/vora-cluster/values.yaml

sudo su - hadoop -c 'ssh-keyscan localhost,0.0.0.0,master > ~/.ssh/known_hosts'
sudo su - hadoop -c 'hdfs namenode -format -force'
sudo su - hadoop -c '$HADOOP_HOME/sbin/start-dfs.sh'
sudo su - hadoop -c '$HADOOP_HOME/sbin/start-yarn.sh'
sudo su - hadoop -c 'hdfs dfs -mkdir -p /user/vora/lib'
sudo su - hadoop -c 'hdfs dfs -put /opt/vora-spark/lib/spark-sap-datasources-spark2.jar /user/vora/lib/'
sudo su - hadoop -c 'python /datahub/SAPVora-SparkIntegration/lib/auth_config.py --username default\\vora --password cubisvora > /home/hadoop/v2auth.conf'

nohup kubectl proxy --address=10.11.12.10 --port=8001 --accept-hosts='^*$' &

sleep 10

# Installation of data Provisioning Agent and Data Hub Adapter for hadoop access.
sudo /vagrant/SAPCAR.EXE -xvf /vagrant/IMDB_DPAGENT.SAR -R /home/hadoop
sudo chown hadoop:hadoop -R /home/hadoop/HANA_DP_AGENT_20_LIN_X86_64
sudo mkdir -p /usr/sap/dataprovagent
sudo chown hadoop:hadoop /usr/sap/dataprovagent


exit
