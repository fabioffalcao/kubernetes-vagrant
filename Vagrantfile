# -*- mode: ruby -*-
# vi: set ft=ruby :

HAPROXY       = "172.16.8.10"
MASTER_01_IP       = "172.16.8.11"
MASTER_02_IP       = "172.16.8.12"
MASTER_03_IP       = "172.16.8.13"
NODE_01_IP      = "172.16.8.20"
NODE_02_IP      = "172.16.8.21"
NODE_03_IP      = "172.16.8.22"

Vagrant.configure("2") do |config|

  boxes = [
    { :name => "haproxy",  :ip => HAPROXY,  :cpus => 2, :memory => 1024, :image => "generic/ubuntu2004" },
    { :name => "master-01",  :ip => MASTER_01_IP,  :cpus => 2, :memory => 2048, :image => "generic/ubuntu2004" },
    #{ :name => "master-02",  :ip => MASTER_02_IP,  :cpus => 2, :memory => 2048, :image => "generic/ubuntu2004" },
    #{ :name => "master-03",  :ip => MASTER_03_IP,  :cpus => 2, :memory => 2048, :image => "generic/ubuntu2004" },
    { :name => "node-01", :ip => NODE_01_IP, :cpus => 2, :memory => 1024, :image => "generic/ubuntu2004" },
    { :name => "node-02", :ip => NODE_02_IP, :cpus => 2, :memory => 1024, :image => "generic/ubuntu2004" },
    #{ :name => "node-03", :ip => NODE_03_IP, :cpus => 2, :memory => 1024, :image => "ubuntu/bionic64" },
  ]

  boxes.each do |opts|
    config.vm.define opts[:name] do |box|
      box.vm.box = opts[:image]
      box.vm.hostname = opts[:name]
      box.vm.network :private_network, ip: opts[:ip]
 
      box.vm.provider "virtualbox" do |vb|
        vb.name = opts[:name]
        vb.cpus = opts[:cpus]
        vb.memory = opts[:memory]
      end

      if box.vm.hostname == "haproxy" then 
        box.vm.provision "shell", path:"./scripts/install-haproxy.sh"
      else
        box.vm.provision "shell", path:"./scripts/install-kubernetes-dependencies.sh"

        #if box.vm.hostname == "master-01" || box.vm.hostname == "master-02" || box.vm.hostname == "master-03"  then 
        #  box.vm.provision "shell", path:"./scripts/configure-master-node.sh"
        #else
        #  box.vm.provision "shell", path:"./scripts/configure-worker-nodes.sh"
        #end
      end
      

#      config.vm.provision "shell", env: {"MASTER_01_IP" => MASTER_01_IP, "MASTER_02_IP" => MASTER_02_IP, "MASTER_03_IP" => MASTER_03_IP, "NODE_01_IP" => NODE_01_IP, "NODE_02_IP" => NODE_02_IP, "NODE_03_IP" => NODE_03_IP}, inline: <<-SHELL
#      apt-get update -y
#      echo "$MASTER_01_IP master-01" >> /etc/hosts
#      echo "$MASTER_02_IP master-02" >> /etc/hosts
#      echo "$MASTER_03_IP master-03" >> /etc/hosts
#      echo "$NODE_01_IP node-01" >> /etc/hosts
#      echo "$NODE_02_IP node-02" >> /etc/hosts
#      echo "$NODE_03_IP node-03" >> /etc/hosts
#      SHELL



    end
  end
end
