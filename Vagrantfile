# VARS

ENV["LC_ALL"] = "en_US.UTF-8"

# MACHINES
# default installation data
IMAGE_NAME = "bento/debian-11"
DEF_SH="scripts/default.sh"
PROVIDER="virtualbox"
MASTER_RAM="2048"
MASTER_CPU="2"
NODE_RAM="1024"
NODE_CPU="1"
# MASTER NODE SETUP
MASTER="master"
MASTER_SH="scripts/master.sh"
# WORKER NODE[S] SETUP
NODE="node-"
NODE_SH="scripts/node.sh"
N=2
# NETWORK
IP="192.168.254.23"
FORWARD="323"
MASK="255.0.0.0"
SSH="22"
VLAN="KUBE"





Vagrant.configure("2") do |config|
    config.ssh.insert_key = false

	# populate /etc/hosts
	config.vm.provision "shell", inline: <<-SHELL
		apt-get update -y
		echo -e ""#{IP}0" "master"" >> /etc/hosts
		echo -e ""#{IP}1" "node-1"" >> /etc/hosts
		echo -e ""#{IP}2" "node-2"" >> /etc/hosts
	SHELL
      
	config.vm.box = IMAGE_NAME
	config.ssh.private_key_path = "./keys/id_ed25519"
	config.ssh.forward_agent = true
	config.ssh.username = 'vagrant'
	config.ssh.password = 'vagrant'
	# Disable vbguest installation if plugin available
	if Vagrant.has_plugin?("vagrant-vbguest")
		config.vbguest.auto_update = false
	end
	Vagrant::Config.run do |config|
		config.vbguest.iso_path = " C:/Users/s1172350/Downloads/VBoxGuestAdditions_5.2.8.iso"
		config.vbguest.iso_path = "http://company.server/VirtualBox/$VBOX_VERSION/VBoxGuestAdditions.iso"
	end
	
    config.vm.define MASTER do |master|
	master.vm.network "forwarded_port", guest: SSH, host: "#{FORWARD}0"
	master.vm.network "public_network" 
	master.vm.network "private_network", ip: "#{IP}0", netmask: MASK , virtualbox__intnet: VLAN
        master.vm.hostname = MASTER
	master.vm.synced_folder "../", "/vagrant_data", type: PROVIDER
       # master.vm.provision "ansible" do |ansible|
       #     ansible.playbook = "ansible/master-playbook.yml"
       #     ansible.extra_vars = {
       #         node_ip: MASTER,
       #     }
       # end
		config.vm.provider PROVIDER do |v|
			v.memory = MASTER_RAM
			v.cpus = MASTER_CPU
		end
		master.vm.provision "shell", path: DEF_SH
		master.vm.provision "shell", path: MASTER_SH
    end

    (1..N).each do |i|
        config.vm.define "#{NODE}#{i}" do |node|
			node.vm.network "forwarded_port", guest: SSH, host: "#{FORWARD}#{i}"
			node.vm.network "public_network" 
			node.vm.network "private_network", ip: "#{IP}#{i}", netmask: MASK , virtualbox__intnet: VLAN
			node.vm.synced_folder "../", "/vagrant_data", type: PROVIDER
            node.vm.hostname = "#{NODE}#{i}"
            #node.vm.provision "ansible" do |ansible|
            #    ansible.playbook = "ansible/node-playbook.yml"
            #    ansible.extra_vars = {
            #        node_ip: "#{NODE}#{i}",
            #    }
            #end
			config.vm.provider PROVIDER do |v|
				v.memory = NODE_RAM
				v.cpus = NODE_CPU
			end
			node.vm.provision "shell", path: DEF_SH
			node.vm.provision "shell", path: NODE_SH
        end
    end
end
