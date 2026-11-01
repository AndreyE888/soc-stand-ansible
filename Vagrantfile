# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04"
  config.vm.box_check_update = false

  # Отключаем стандартный shared folder (не нужен)
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # SSH-ключ Vagrant (insecure_private_key)
  config.ssh.insert_key = false

  # VM docker
  config.vm.define "docker" do |node|
    node.vm.hostname = "docker"
    node.vm.network "private_network", ip: "192.168.57.10"
    node.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
      vb.customize ["modifyvm", :id, "--cableconnected2", "on"]
    end
  end

  # VM docker_registry
  config.vm.define "docker_registry" do |node|
    node.vm.hostname = "docker-registry"
    node.vm.network "private_network", ip: "192.168.57.11"
    node.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
      vb.customize ["modifyvm", :id, "--cableconnected2", "on"]
    end
  end

  # VM storage
  config.vm.define "storage" do |node|
    node.vm.hostname = "storage"
    node.vm.network "private_network", ip: "192.168.57.12"
    node.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
      vb.customize ["modifyvm", :id, "--cableconnected2", "on"]
    end
  end

  # Поднять eth1 (Host-Only) после загрузки
  # Ubuntu 24.04 не имеет dhclient, поэтому ip link set — единственный способ поднять eth1 (Host-Only) и дождаться IP
  config.vm.provision "shell", run: "always", inline: <<-SHELL
    echo "Waiting for eth1 to get an IP..."
    for i in {1..30}; do
      # Проверяем, есть ли у eth1 IP-адрес
      if ip addr show eth1 2>/dev/null | grep -q "192.168.57."; then
        echo "eth1 is up with IP."
        break
      fi
      sudo ip link set eth1 up 2>/dev/null || true
      # Пробуем запросить IP, если есть dhclient
      if command -v dhclient >/dev/null; then
        sudo dhclient eth1 2>/dev/null || true
      fi
      sleep 1
    done
    # Финальная страховка
    sudo ip link set eth1 up || true
  SHELL
end
