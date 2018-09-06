# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_IMAGE = "ubuntu/xenial64"
NODE_COUNT = 3 
NODE_IP_NW = "10.11.12."
NODE_MEM = "4096"

Vagrant.configure("2") do |config|
  
  config.vm.box = BOX_IMAGE 
  config.vm.box_check_update = false
  
  config.disksize.size = "50GB"

  config.vm.provider "virtualbox" do |l|
    l.cpus = 4
    l.memory = NODE_MEM 
  end

  config.hostmanager.enabled = true
  config.hostmanager.manage_guest = true

  (1..NODE_COUNT).each do |i|
    if i == 1
      config.vm.define "master" do |subconfig|
        subconfig.vm.hostname = "master"
        subconfig.vm.network :private_network, ip: NODE_IP_NW + "#{i + 9}"
        subconfig.vm.provision :shell, :path => "provision.sh", :args => "'master'"
        subconfig.trigger.after :up do |trigger|
          trigger.info = "Starting dashboard ..."
          trigger.run_remote = { inline: "/vagrant/master-postprocessing.sh" }
	end
      end
    else
      config.vm.define "node#{i - 1}" do |subconfig|
        subconfig.vm.hostname = "node#{i - 1}"
        subconfig.vm.network :private_network, ip: NODE_IP_NW + "#{i + 9}"
        subconfig.vm.provision :shell, :path => "provision.sh", :args => "'node'"
      end
    end
  end
end
