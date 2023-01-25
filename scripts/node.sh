mkdir -p /KLUSTER
echo "192.168.254.230:/KLUSTER /KLUSTER  nfs      defaults    0       0" >> /etc/fstab
mount -a
vagrant/k8s_kluster_join_command.sh

