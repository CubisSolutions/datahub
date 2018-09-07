# datahub
SAP Data Hub 1.4 / Vora 2.2

## Vagrant
The setup/deployment of the the Kubernetes cluster, hadoop system and extraction of the Datahub ZIP files has been orchestrated in a vagrant setup. So in order to spin up the VMs needed for running the cluster, you should have vagrant installed on your local machine. The version of vagrant used in this setup is 2.1.2. The setup was done in combination with VirtualBox VM software.

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
After the initial setup you should be able to access the [Kubernetes Dashboard](http://10.11.12.10:8001/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/), the [Yarn Cluster Manager Webui](http://10.11.12.10:8088/cluster) and the [Hadoop Webui](http://10.11.12.10:50070).

Now that the Kubernets cluster is running, the SAP Data Hub and Vora deployment can be started from the master node.

```
# Step to determine which Kubernetes nodes are availbe for stateful-sets. Needs to be run before final deployment.
/datahub/SAPVora-2.2.48-DistributedRuntime/install.sh --assign-nodes --namespace=vora --docker-registry=10.11.12.10:5000

# Start deployment
/datahub/SAPVora-2.2.48-DistributedRuntime/install.sh --namespace=vora --docker-registry=10.11.12.10:5000 -a --vora-admin-username=vora --vora-admin-password=cubisvora --provision-persistent-volumes=yes --nfs-address=master --nfs-path=/mnt/voranfs --local-nfs-path=/mnt/share --cert-domain=master -dt=onpremise --vsolution-import-path=/datahub/bdh-assembly-vsystem --interactive-security-configuration=no -ss=vora-diagnostic
```

When correctly deployed, you should see information about the ports that are used by vsystem and vora-tx-coordinator. Via the vsystem webui, you can startup the Vora Tools and SAP Data Hub Pipeline

![voraports](https://github.com/CubisSolutions/datahub/raw/master/assets/ports.png?raw=true, "ports picture")

In your favourite browser, start the "SAP DATA Hub System Management" webui using [https://10.11.12.10:](https://10.11.12.10)*vsystem-port*.
You should be redirected to the screen below. Because the site is using a self-signed certificate, you will have to explicitely proceed to the page.
![datahublogin](https://github.com/CubisSolutions/datahub/raw/master/assets/datahubloginscreen.png?raw=true, "datahubloginscreen picture")

The "Tenant ID" is **default**  
The "Username" is **vora** *(or the user id provided during the data hub installation script in case it was changed)*  
The "Password" is **cubisvora** *(or the password provided with the installation script)*  
