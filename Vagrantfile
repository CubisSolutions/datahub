# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_IMAGE = "ubuntu/xenial64"
NODE_COUNT = 4 
NODE_IP_NW = "10.11.12."
NODE_MEM = "3584"

Vagrant.configure("2") do |config|
  
  config.vm.box = BOX_IMAGE 
  config.vm.box_check_update = false
  
  config.disksize.size = "50GB"

  config.vm.provider "virtualbox" do |l|
    l.cpus = 2 
    l.memory = NODE_MEM 
  end

  config.hostmanager.enabled = true
  config.hostmanager.manage_guest = true

  (1..NODE_COUNT).each do |i|
    if i == 1
      config.vm.define "master" do |subconfig|
        subconfig.vm.network "forwarded_port", guest: 8001, host: 8001
#        for j in 30000 .. 32767
#          subconfig.vm.network :forwarded_port, guest: j, host: j
#        end
        subconfig.vm.hostname = "master"
        subconfig.vm.network :private_network, ip: NODE_IP_NW + "#{i + 9}"
	subconfig.vm.provision :shell, :path => "provision.sh", :args => "'master'"
        subconfig.trigger.after :up do |trigger|
          trigger.info = "Starting dashboard ..."
          trigger.run_remote = { inline: "/vagrant/master-postprocessing.sh" }
	end
      end
    else
      if i == 2
        config.vm.define "hadoop" do |subconfig|
	  subconfig.vm.hostname = "hadoop"
          subconfig.vm.network :private_network, ip: NODE_IP_NW + "#{i + 9}"
          subconfig.vm.network "forwarded_port", guest: 50070, host: 50070
          subconfig.vm.network "forwarded_port", guest: 9000, host: 9000 
          subconfig.vm.network "forwarded_port", guest: 8088, host: 8088 
          subconfig.vm.network "forwarded_port", guest: 8044, host: 8044 
          subconfig.vm.network "forwarded_port", guest: 8042, host: 8042 
          subconfig.vm.provision :shell, :path => "provision.sh", :args => "'hadoop'"
          subconfig.trigger.after :up do |trigger|
            trigger.info = "Starting dashboard ..."
            trigger.run_remote = { inline: "/vagrant/hadoop-postprocessing.sh" }
	end
	end
      else
        config.vm.define "node#{i - 2}" do |subconfig|
          subconfig.vm.hostname = "node#{i - 2}"
          subconfig.vm.network :private_network, ip: NODE_IP_NW + "#{i + 9}"
          subconfig.vm.provision :shell, :path => "provision.sh", :args => "'node'"
	  if i == NODE_COUNT
	    subconfig.trigger.after :up do |trigger|
	      trigger.info = "Staring node2 postprocessing ..."
	      trigger.run_remote = {inline: "/vagrant/node2-postprocessing.sh" }
	    end
	  end
        end
      end
    end
  end

end
