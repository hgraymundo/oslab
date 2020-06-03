   # Desarrollado por marcelo guazzardo
   # mguazzardo76@gmail.com

   yum -y install yum-utils
   yum -y install git vim
   yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
   yum install -y  docker-ce docker-ce-cli containerd.io
   mkdir -p /etc/docker /etc/containers

   #Disabling selinux.
   sed -i 's/enforcing/disabled/g' /etc/selinux/config
   setenforce 0

   cat << EOF >/etc/docker/daemon.json
   {
      "insecure-registries": [
      "172.30.0.0/16"
      ]
   }
   EOF

   cat << EOF > /etc/containers/registries.conf
   [registries.insecure]
   registries = ['172.30.0.0/16']
   EOF


   sudo systemctl daemon-reload
   sudo systemctl restart docker
   sudo systemctl enable docker
   echo "net.ipv4.ip_forward = 1"
   sysctl -p
   iptables -I INPUT -p tcp --dport 8443 -j ACCEPT
   DOCKER_BRIDGE=`docker network inspect -f "{{range .IPAM.Config }}{{ .Subnet }}{{end}}" bridge`
   sudo firewall-cmd --permanent --new-zone dockerc
   sudo firewall-cmd --permanent --zone dockerc --add-source $DOCKER_BRIDGE
   sudo firewall-cmd --permanent --zone dockerc --add-port={80,443,8443}/tcp
   sudo firewall-cmd --permanent --zone dockerc --add-port={53,8053}/udp
   sudo firewall-cmd --reload
   iptables -I INPUT -p tcp --dport 8443 -j ACCEPT
   iptables -I INPUT -p tcp --dport 8080 -j ACCEPT
   iptables -I INPUT -p tcp --dport 443 -j ACCEPT
   iptables -I INPUT -p tcp --dport 80 -j ACCEPT

   yum -y install wget
   systemctl restart docker
   cd /tmp/
   wget https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
   tar xvf openshift-origin-client-tools*.tar.gz
   cd openshift-origin-client*/
   sudo mv  oc kubectl  /usr/local/bin/
   oc version

