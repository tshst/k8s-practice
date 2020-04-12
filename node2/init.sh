#!/bin/bash

# set environments
nodename=$1

# this script target bionic64. 
# see also:https://docs.docker.com/install/linux/docker-ce/ubuntu/

# set up the repository
sudo apt update
sudo apt -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# point:fingeprint check
# sudo apt-key fingerprint 0EBFCD88

# pub   rsa4096 2017-02-22 [SCEA]
#       9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
# uid           [ unknown] Docker Release (CE deb) <docker@docker.com>
# sub   rsa4096 2017-02-22 [S]

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# set hostname
sudo hostnamectl set-hostname ${nodename}
sudo sh -c 'cat >> /etc/hosts <<EOF
192.168.100.10 master
192.168.100.11 node1
192.168.100.12 node2
EOF'

# install docker
sudo apt update
sudo apt -y install docker-ce docker-ce-cli containerd.io

# Setup daemon.
sudo sh -c 'cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF'

sudo mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
sudo systemctl daemon-reload
sudo systemctl restart docker

# install base package
sudo apt -y install git

## kubernetes setup
# Letting iptables see bridged traffic
sudo sh -c 'cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF'
sudo sysctl --system

# ensure legacy binaries are installed
sudo apt-get install -y iptables arptables ebtables

# switch to legacy versions
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
sudo update-alternatives --set arptables /usr/sbin/arptables-legacy
sudo update-alternatives --set ebtables /usr/sbin/ebtables-legacy

# swap off
sudo swapoff -a
sudo sed -e "/^UUID=[a-z0-9-]* swap/s/^/# /" -i.bak /etc/fstab

# install kubeadm, kubelet, kubectl
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# iptables backup
dir=/etc/iptables
file=${dir}/rules.v4

if [ ! -e ${dir} ]
then
    sudo mkdir ${dir} && sudo touch ${file} && sudo sh -c "iptables-save > ${file}"
else
    sudo touch ${file} && sudo  sh -c "iptables-save > ${file}"
fi

exit 0
