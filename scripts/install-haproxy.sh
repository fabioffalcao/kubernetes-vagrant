#!/bin/bash -e


install_required_packages ()
{
sudo apt update
sudo apt -y install curl haproxy jq vim net-tools
}

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

configure_haproxy ()
{
cat <<EOF >> /etc/haproxy/haproxy.cfg

#LOAD BALANCE FOR K8S API
#frontend k8s
#    mode tcp
#    bind *:6443
#    option tcplog
#    default_backend k8s-masters

#backend k8s-masters
#    option httpchk GET /healthz
#    http-check expect status 200
#    mode tcp
#    option ssl-hello-chk
#    balance roundrobin
#    server k8s-master-01 master-01:6443 check
#    server k8s-master-02 master-02:6443 check
#    server k8s-master-03 master-03:6443 check

frontend k8s
    mode tcp
    bind haproxy:6443
    option tcplog
    default_backend k8s-masters

backend k8s-masters
    mode tcp
    balance roundrobin
    option tcp-check
    server k8s-master-01 master-01:6443 check fall 3 rise 2
    server k8s-master-02 master-02:6443 check fall 3 rise 2
    server k8s-master-03 master-03:6443 check fall 3 rise 2
EOF

sudo systemctl restart haproxy

}
install_required_packages
configure_hosts_file
configure_haproxy
