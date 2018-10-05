#!/bin/sh

port=$(cat /vagrant/shared/txcoordinatorport.txt)
echo "vora-tx-coordinator port is $port"
sudo sed -i -e "s/txport/$port/" /srv/spark/conf/spark-defaults.conf
sudo rm /bin/sh
sudo ln -s /bin/bash /bin/sh
sudo su - vagrant -c 'HANA_DP_AGENT_20_LIN_X86_64/hdbinst --batch --path /usr/sap/dataprovagent'
sudo su - vagrant -c 'BDH_ADAPTER_LIN_X86_64/hdbinst --batch --path=/usr/sap/dataprovagent/bdh --hadoopConfDir=/srv/hadoop/etc/hadoop --voraHome=/opt/vora-spark --sparkConfDir=/srv/spark/conf'

exit

