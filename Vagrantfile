# coding: utf-8
Vagrant.configure(2) do |config|

  # BIRD Route Server
  config.vm.define :bird do |bird|
    bird.vm.box = "bento/debian-9.4"
    bird.vm.network "private_network", virtualbox__intnet: "ix_nw1", auto_config: false
      bird.vm.provider "virtualbox" do |v|
        v.cpus = 2
        v.memory = 2048
      end
    bird.vm.provision "shell", privileged: true, inline: <<-EOS
      # jp
      apt-get update
      apt-get install -y git vim autoconf flex bison libncurses-dev libreadline-gplv2-dev build-essential
      echo "auto eth1"               >  /etc/network/interfaces.d/eth1
      echo "iface eth1 inet static"  >> /etc/network/interfaces.d/eth1
      echo " address 10.0.0.100"     >> /etc/network/interfaces.d/eth1
      echo " netmask 255.255.255.0"  >> /etc/network/interfaces.d/eth1
      echo "iface eth1 inet6 static" >> /etc/network/interfaces.d/eth1
      echo " address 2001:db8::100"  >> /etc/network/interfaces.d/eth1
      echo " netmask 64"             >> /etc/network/interfaces.d/eth1
      ifup eth1
      cp /vagrant/provisioning/bird.service /etc/systemd/system
      cp /vagrant/provisioning/bird6.service /etc/systemd/system
      ln -s /vagrant/provisioning/bird /etc/bird
      ln -s /vagrant/provisioning/bird6 /etc/bird6
      cd /tmp
      wget https://github.com/BIRD/bird/archive/v1.6.4.tar.gz
      tar zxvf v1.6.4.tar.gz
      cd bird-1.6.4
      autoconf
      autoheader
      ./configure
      make
      sudo make install
      ./configure --enable-ipv6
      make
      sudo make install
    EOS
  end

  # BIRD Clients #1-4
  (1..4).each do |i|
    config.vm.define "gobgp#{i}" do |gobgp|
      gobgp.vm.box = "bento/debian-9.4"
      gobgp.vm.network "private_network", virtualbox__intnet: "ix_nw1", auto_config: false
      gobgp.vm.provider "virtualbox" do |v|
        v.cpus = 1
        v.memory = 512
      end
      gobgp.vm.provision "shell", privileged: true, inline: <<-EOS
        apt-get update
        apt-get install -y git vim
        cp /vagrant/gobgp/gobgp /usr/local/bin
        cp /vagrant/gobgp/gobgpd /usr/local/bin
        cp /vagrant/provisioning/gobgp.service /etc/systemd/system
        ln -s /vagrant/provisioning/gobgp#{i} /etc/gobgp
      EOS
      if [1, 2, 3].include?(i) then
        gobgp.vm.provision "shell", privileged: true, inline: <<-EOS
          echo "auto eth1"               >  /etc/network/interfaces.d/eth1
          echo "iface eth1 inet static"  >> /etc/network/interfaces.d/eth1
          echo " address 10.0.0.#{i}"    >> /etc/network/interfaces.d/eth1
          echo " netmask 255.255.255.0"  >> /etc/network/interfaces.d/eth1
          echo "iface eth1 inet6 static" >> /etc/network/interfaces.d/eth1
          echo " address 2001:db8::#{i}" >> /etc/network/interfaces.d/eth1
          echo " netmask 64"             >> /etc/network/interfaces.d/eth1
          ifup eth1
        EOS
      end
      if [1, 4].include?(i) then
        gobgp.vm.network "private_network", virtualbox__intnet: "pni_nw1", auto_config: false
        gobgp.vm.provision "shell", privileged: true, inline: <<-EOS
          echo "auto eth2"                 >  /etc/network/interfaces.d/eth2
          echo "iface eth2 inet static"    >> /etc/network/interfaces.d/eth2
          echo " address 10.0.1.#{i}"      >> /etc/network/interfaces.d/eth2
          echo " netmask 255.255.255.248"  >> /etc/network/interfaces.d/eth2
          echo "iface eth2 inet6 static"   >> /etc/network/interfaces.d/eth2
          echo " address 2001:db8:1::#{i}" >> /etc/network/interfaces.d/eth2
          echo " netmask 64"               >> /etc/network/interfaces.d/eth2
          ifup eth2
        EOS
      end
      gobgp.vm.provision "shell", privileged: true, inline: <<-EOS
        systemctl enable gobgp
        systemctl start gobgp
      EOS
    end
  end
end
