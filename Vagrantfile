# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version.
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Ubuntu box provided in HashiCorp's Atlas (https://atlas.hashicorp.com/boxes/search).
  config.vm.box = "ubuntu/trusty64"

  # Allow vagrant to check for more recent versions of the virtual machine.
  config.vm.box_check_update = true

  # Create a forwarded port mapping which allows access to a specific port within the
  # machine from a port on the host machine.
  config.vm.network "forwarded_port", guest: 80, host: 7003

  # A private network that allows host-only access to the machine using a specific IP.
  config.vm.network "private_network", ip: "192.168.44.46"

  # Define the amount of memory allocated to the machine. Modify as necessary.
  config.vm.provider "virtualbox" do |vb|
   vb.customize ["modifyvm", :id, "--memory", "2048"]
  end
  
  # A list of scripts that will be run the first time the box is started.
  config.vm.provision "shell", path: "provisioning/installs.sh"
end
