# datahub
SAP Data Hub 2.3

## Vagrant
The setup/deployment of the the Kubernetes cluster, hadoop system and extraction of the Datahub ZIP files has been orchestrated in a vagrant setup. So in order to spin up the VMs needed for running the cluster, you should have vagrant installed on your local machine. The version of vagrant used in this setup is 2.1.2. The setup was done in combination with VirtualBox VM software. Also the Datahub Foundation and Spark Integration ZIP files should be download from the SAP Download centre and placed in the root directory. A valid S-user is needed for this.

Also some agrant plugins need to be installed: 
```
# Installation of the necessary vagrant plugins
vagrant plugin install vagrant-disksize
vagrant plugin install vagrant-hostmanager

# Creation of the VMs: master, node1 and node2
vagrant up

# Entering the shell of the master node.
vagrant ssh master

```
## Text herunder under construction!!! Not yet up-to-date!!!
A kubernetes cluser will be spun-up with one master and two nodes. Also a ceph is deployed via rook as distributed storage system in order to provision the Persistant volumes needed by the SAP DataHub components. Finally the deployment of the datahub software will start. All this will take some time to finish. 

Before starting the vagrant deployment, make a copy of the "credential.sh.template" to "credential.sh" and provide a valid SUSER and SUSERPW for installation validation as well as a datahub user and password that will be created as initial datahub user.

