#!/bin/bash -e

master_node=172.16.8.10
pod_network_cidr=192.168.0.0/16

initialize_master_node ()
{
sudo systemctl enable kubelet
sudo kubeadm config images pull
#sudo kubeadm init --apiserver-advertise-address=172.16.8.11 --pod-network-cidr=192.168.0.0/16 --ignore-preflight-errors=NumCPU
#kubeadm init --control-plane-endpoint "haproxy:6443" --upload-certs --ignore-preflight-errors=NumCPU,Mem

sudo kubeadm init --control-plane-endpoint "haproxy:6443" --upload-certs --apiserver-advertise-address=172.16.8.11 --pod-network-cidr=192.168.0.0/16

#sudo kubeadm init --control-plane-endpoint "172.16.8.11:6443" --upload-certs --apiserver-advertise-address=172.16.8.11 --pod-network-cidr=192.168.0.0/16

}


create_join_command ()
{
kubeadm token create --print-join-command | tee /vagrant/join_command.sh
chmod +x /vagrant/join_command.sh
}

configure_kubectl () 
{
sudo mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

##For vagrant user
mkdir -p /home/vagrant/.kube
sudo cp -f /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown -R vagrant:vagrant /home/vagrant/.kube
}

install_network_cni ()
{
    
#kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml
}

initialize_master_node
configure_kubectl
install_network_cni
create_join_command