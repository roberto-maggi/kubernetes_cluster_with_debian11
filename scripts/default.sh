systemctl set-default multi-user.target
apt-get -y update
apt-get install -y ansible build-essential bzip2 chrony	dkms gcc linux-headers-$(uname -r) make net-tools nfs-common perl avahi-daemon vim 
#apt-get -y remove firewalld-filesystem
if test -e /usr/sbin/iptables ;
	then
		iptables -F
		iptables -X ;
fi
timedatectl set-timezone Europe/Zurich
# user 		vagrant
# password 	vagrant
usermod -aG sudo vagrant
chmod 700 /home/vagrant/		
ln -sf /vagrant/ /home/vagrant/
mkdir -p /home/vagrant/.ssh
chmod -R 700 /home/vagrant/.ssh
cp -a /home/vagrant/vagrant/keys/* /home/vagrant/.ssh/
chmod 600 /home/vagrant/.ssh/*
chown -R vagrant.vagrant /home/vagrant/
# root 
ln -sf /vagrant/ /root/
mkdir -p /root/.ssh
cp -a /home/vagrant/vagrant/keys/* /root/.ssh/
chmod 700 /root/.ssh
chmod 600 /root/.ssh/*
chown -R root.root /root
# VIM
users=(rob vagrant)
for x in ${users[@]}; 
	do
		echo -e 'set mouse-=a' >> /home/$x/.vimrc
		echo -e 'syntax on' >> /home/$x/.vimrc
		echo -e 'colorscheme desert' >> /home/$x/.vimrc
		mkdir /.vim /home/${users[$x]}/.vim/colors;
done

# change root settings and password
# ROOT PASSWORD IS "vagrant"
sed -i '/root/d' /etc/shadow
sed -i '/root/d' /etc/passwd
echo -e 'root:$y$j9T$tjgd7hJotkL7cSHHaTJAo0$5J55fn9g1dc7F4BPph/lXJKCWiinyllwGz3yj0Ll1r4:19376:0:99999:7:::' >> /etc/shadow
echo -e 'root:x:0:0:root:/root:/bin/bash' >> /etc/passwd
cp -a /vagrant/files/chrony.conf /etc/chrony/
chronyc -a makestep
systemctl restart chrony

# k8s
# IF you HAVE to do this by hand use "at least" ansible
# ansible cluster -i  /etc/ansible/inventory.ini -m shell -a "PUT YOUR COMMANDS HERE" -b
[ -e `which setenforce` ] || setenforce 0
#sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux 

swapoff -a
sed -i 's/\/dev\/mapper\/debian--11--vg-swap_1/#\/dev\/mapper\/debian--11--vg-swap_1/g '  /etc/fstab
modprobe br_netfilter 
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables 
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
	overlay
	br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<	EOF | sudo tee /etc/sysctl.d/99-kubernetes-k8s.conf
	net.bridge.bridge-nf-call-iptables = 1
	net.ipv4.ip_forward = 1
	net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system
apt-get -y  update
apt install ca-certificates curl gnupg lsb-release gnupg gnupg2 curl software-properties-common -y
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/cgoogle.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
apt update
apt-get install -y  docker-ce docker-ce-cli containerd.io docker-compose-plugin
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
apt update
apt-get install kubelet kubeadm kubectl -y
apt-mark hold kubelet kubeadm kubectl
systemctl enable docker.service
systemctl start docker.service
systemctl status docker.service
systemctl enable kubelet
systemctl start kubelet

