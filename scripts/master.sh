		############################
		#
		#	project specific 
		#		ONLY for
		#		k8s on debian vms
		#
		############################
		#
		#
		#
		###########################
		
# SSH SETUP
sed -i 's/^#Port 22/Port 22/g' /etc/ssh/sshd_config
sed -i 's/^#PubkeyAuthentication/PubkeyAuthentication/g' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication/PasswordAuthentication/g' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
apt-get -y install ansible nfs-kernel-server
sed -i 's/#Port/Port/g' /etc/ssh/sshd_config
sed -i 's/#AllowAgentForwarding/AllowAgentForwarding/g' /etc/ssh/sshd_config
 
# NFS SHARING
apt-get install -y nfs-kernel-server 
mkdir -p /KLUSTER
echo "/KLUSTER 192.168.254.0/255.255.255.0(sync,rw,no_root_squash,subtree_check)" >> /etc/exports
systemctl restart nfs-server

# ANSIBLE
mkdir -p /etc/ansible
cp -a ansible/inventory.ini /etc/ansible/

# K8S MASTER SETUP -- AFTER THE "DEFAULT SETUP"
# kubeadm init --control-plane-endpoint=master
# kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml
