#!/bin/sh

# Source: http://kubernetes.io/docs/getting-started-guides/kubeadm/

sudo mkdir /datahub
sudo unzip -n /vagrant/DHSPARKINT.ZIP -d /datahub
sudo chmod 755 -R /datahub
sudo chown vagrant:vagrant -R /datahub

# Prepare for spark integration
sudo mkdir /opt/vora-spark
sudo tar -xvf /datahub/SAPVora-SparkIntegration/vora-spark.tar.gz -C /opt/vora-spark

# Add the public key from node2 as authorized ssh client
cat /vagrant/shared/id_rsa.pub >> /home/vagrant/authorized_keys

sudo su - vagrant -c 'cp /vagrant/shared/id_rsa* .ssh/'
sudo su - vagrant -c 'chmod 600 .ssh/id_rsa*'
sudo su - vagrant -c 'cat .ssh/id_rsa.pub >> .ssh/authorized_keys'
sudo su - vagrant -c 'ssh-keyscan localhost,0.0.0.0,hadoop > ~/.ssh/known_hosts'
sudo su - vagrant -c 'hdfs namenode -format -force'
sudo su - vagrant -c '$HADOOP_HOME/sbin/start-dfs.sh'
sudo su - vagrant -c '$HADOOP_HOME/sbin/start-yarn.sh'
sudo su - vagrant -c 'hdfs dfs -mkdir -p /user/vora/lib'
sudo su - vagrant -c 'hdfs dfs -put /opt/vora-spark/lib/spark-sap-datasources-spark2.jar /user/vora/lib/'
sudo su - vagrant -c 'python /datahub/SAPVora-SparkIntegration/lib/auth_config.py --username default\\vora --password cubisvora > /home/vagrant/v2auth.conf'

# Installation of data Provisioning Agent and Data Hub Adapter for hadoop access.
sudo /vagrant/SAPCAR.EXE -xvf /vagrant/IMDB_DPAGENT.SAR -R /home/vagrant
sudo unzip -o /vagrant/DHSDIADAPTER.ZIP -d /home/vagrant
sudo chown vagrant:vagrant -R /home/vagrant/HANA_DP_AGENT_20_LIN_X86_64
sudo chown vagrant:vagrant -R /home/vagrant/BDH_ADAPTER_LIN_X86_64
sudo mkdir -p /usr/sap/dataprovagent
sudo chown vagrant:vagrant /usr/sap/dataprovagent

exit
