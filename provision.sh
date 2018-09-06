#!/bin/sh

# Source: http://kubernetes.io/docs/getting-started-guides/kubeadm/

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update

apt-get install -y kubelet=1.7.16-00 kubeadm=1.7.16-00 kubectl=1.7.15-00 kubernetes-cni=0.5.1-00
apt-get install -y docker.io rpcbind nfs-common nfs-kernel-server unzip python-pip

pip install pyyaml

sudo cp /vagrant/daemon.json /etc/docker/daemon.json
sudo /etc/init.d/docker restart

sudo gpasswd -a vagrant docker

sudo mkdir /mnt/share
sudo chmod 777 /mnt/share

sudo swapoff -a

if [ "$1" = "master" ]
then
  # Deploy hadoop on master node.  
  sudo addgroup hadoop   
  sudo useradd -m -g hadoop hadoop   
  sudo usermod -a -G hadoop vagrant

  apt-get install -y openjdk-8-jre-headless
  wget http://www-eu.apache.org/dist/hadoop/common/stable/hadoop-2.9.1.tar.gz
  wget http://apache.cu.be/spark/spark-2.1.3/spark-2.1.3-bin-hadoop2.7.tgz
  tar -xzf hadoop-2.9.1.tar.gz
  tar -xzf spark-2.1.3-bin-hadoop2.7.tgz
  mv hadoop-2.9.1 /srv/
  mv spark-2.1.3-bin-hadoop2.7 /srv/
  
  ln -s /srv/hadoop-2.9.1 /srv/hadoop
  ln -s /srv/spark-2.1.3-bin-hadoop2.7 /srv/spark

  mkdir -p /var/app/hadoop/data
  chown hadoop:hadoop -R /var/app/hadoop

  sed -i 's#${JAVA_HOME}#/usr/lib/jvm/java-8-openjdk-amd64#' /srv/hadoop/etc/hadoop/hadoop-env.sh
  cp /vagrant/core-site.xml /srv/hadoop/etc/hadoop/core-site.xml
  cp /vagrant/mapred-site.xml /srv/hadoop/etc/hadoop/mapred-site.xml
  cp /vagrant/hdfs-site.xml /srv/hadoop/etc/hadoop/hdfs-site.xml
  cp /vagrant/yarn-site.xml /srv/hadoop/etc/hadoop/yarn-site.xml
  cp /vagrant/spark-env.sh /srv/spark/conf/spark-env.sh

  chown hadoop:hadoop -R /srv/hadoop-2.9.1
  chown hadoop:hadoop -R /srv/spark-2.1.3-bin-hadoop2.7
  
  sudo su - hadoop -c 'echo "export HADOOP_HOME=/srv/hadoop" >> /home/hadoop/.profile'
  sudo su - hadoop -c 'echo "export SPARK_HOME=/srv/spark" >> /home/hadoop/.profile'
  sudo su - hadoop -c 'echo "export PATH=\$PATH:\$HADOOP_HOME/bin:\$SPARK_HOME/bin" >> /home/hadoop/.profile'
  sudo su - hadoop -c 'echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /home/hadoop/.profile'

  mkdir /home/hadoop/.ssh
  chown hadoop:hadoop /home/hadoop/.ssh
  sudo su - hadoop -c 'ssh-keygen -f /home/hadoop/.ssh/id_rsa -q -N ""'
  sudo su - hadoop -c 'cp /home/hadoop/.ssh/id_rsa.pub /home/hadoop/.ssh/authorized_keys'
  sudo su - hadoop -c 'chmod 600 /home/hadoop/.ssh/authorized_keys'

  # Remove master definition to prevent issues with HDFS
  sed -i '/127.0.1.1/d' /etc/hosts

  token=$(kubeadm token generate)
  sudo kubeadm init --apiserver-advertise-address=10.11.12.10 --pod-network-cidr=10.244.0.0/16 --token=$token
  echo $token > /vagrant/shared/token.txt

  mkdir /vora
  mkdir $HOME/.kube
  mkdir /home/vagrant/.kube

  sudo mkdir /mnt/voranfs
  sudo mkdir /mnt/voranfs/vora
  sudo mkdir /mnt/voranfs/vora/vsystem
  sudo chmod 777 -R /mnt/voranfs

  sudo cp /vagrant/exports /etc/exports
  sudo exportfs -arvf

  sudo cp -f /etc/kubernetes/admin.conf /home/vagrant/.kube/config
  sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown vagrant:vagrant -R /home/vagrant/.kube
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

  kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

  kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.7.1/src/deploy/alternative/kubernetes-dashboard.yaml

  kubectl apply -f /vagrant/dashboard-admin.yaml

  docker run -d -p 5000:5000 --restart always --name registry registry:2

  curl -LO https://storage.googleapis.com/kubernetes-helm/helm-v2.6.1-linux-amd64.tar.gz > helm-v2.6.1-linux-amd64.tar.gz
  gunzip helm-v2.6.1-linux-amd64.tar.gz
  tar xvf helm-v2.6.1-linux-amd64.tar
  sudo mv linux-amd64/helm /usr/bin/helm
  rm helm-v2.6.1-linux-amd64.tar

  kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
#  kubectl proxy --address=10.11.12.10 --port=8001 --accept-hosts='^*$' &
else
  token=`cat /vagrant/shared/token.txt` 
  echo "Applying token: $token"
  kubeadm join --token $token 10.11.12.10:6443
fi

