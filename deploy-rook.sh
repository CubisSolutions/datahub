#!/bin/sh

kubectl create -f /vagrant/operator.yaml
kubectl create -f /vagrant/cluster.yaml
kubectl create -f /vagrant/dashboard-external-https.yaml
kubectl create -f /vagrant/filesystem.yaml
kubectl create -f /vagrant/object.yaml
kubectl create -f /vagrant/storageclass.yaml
