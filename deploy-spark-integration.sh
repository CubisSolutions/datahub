#!/bin/sh

# Get vora-tx-coordinator port
port=$(kubectl get services -n vora vora-tx-coordinator | grep -o -P '(?<=10002:).*(?=/TCP)')
echo "vora-tx-coordinator port is $port"
sudo sed -i -e "s/txport/$port/" /srv/spark/conf/spark-defaults.conf
exit

