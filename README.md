# datahub
SAP Data Hub 1.4 / Vora 2.2

## Vagrant
The setup/deployment of the the Kubernetes cluster, hadoop system and extraction of the Datahub ZIP files has been orchestrated in a vagrant setup. So in order to spin up the VMs needed for running the cluster, you should have vagrant installed on your local machine. The version of vagrant used in this setup is 2.1.2. The setup was done in combination with VirtualBox VM software.

Also some agrant plugins need to be installed: 
```
vagrant plugin install vagrant-disksize
vagrant plugin install vagrant-hostmanager
```

After the initial setup you should be able to access the [Kubernetes Dashboard](http://http://10.11.12.10:8001/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/)

