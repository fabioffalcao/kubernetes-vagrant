#!/bin/bash -e

configure_hosts_file ()
{
sudo tee /etc/hosts<<EOF
172.16.8.10 haproxy
172.16.8.11 master-01
172.16.8.12 master-02
172.16.8.13 master-03
172.16.8.20 node-01
172.16.8.21 node-02
172.16.8.22 node-03
EOF
}

disable_swap () 
{
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a
sudo systemctl disable --now ufw
}

configure_sysctl ()
{
cat <<EOF | sudo tee /etc/modules-load.d/kubernetes.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system
}

install_container_runtime () 
{

OS=xUbuntu_20.04
VERSION=1.23

sudo cat >>/etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list<<EOF
deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /
EOF

sudo cat >>/etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list<<EOF
deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /
EOF

curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers.gpg add -
curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/Release.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers-cri-o.gpg add -

sudo apt update -y && sudo apt install -qq -y cri-o cri-o-runc cri-tools

sudo cat >>/etc/crio/crio.conf.d/02-cgroup-manager.conf<<EOF
[crio.runtime]
conmon_cgroup = "pod"
cgroup_manager = "systemd"
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now crio

}


install_required_packages ()
{

sudo apt -y install curl apt-transport-https ca-certificates jq net-tools vim git wget

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt update -y

sudo apt install -qq -y kubeadm kubelet kubectl 
}

configure_hosts_file
disable_swap
configure_sysctl
install_container_runtime
install_required_packages
