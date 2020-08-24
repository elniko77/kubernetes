#!/bin/bash

CPUS="2"
MEM="2G"
DISCO="8G"
UBUNTUVER="20.04"
MULTIPASS="multipass.exe"
USER="ubuntu"

MASTER="k3sup-master"
WORKER1="k3sup-worker1"
WORKER2="k3sup-worker2" 

# Bajar e instalar k3sup
curl -sLS https://get.k3sup.dev | sh
sudo cp k3sup /usr/local/bin/k3sup

# Crear las vms
$MULTIPASS launch --name $MASTER --cpus $CPUS --mem $MEM --disk $DISCO $UBUNTUVER
$MULTIPASS launch --name $WORKER1 --cpus $CPUS --mem $MEM --disk $DISCO $UBUNTUVER  
$MULTIPASS launch --name $WORKER2 --cpus $CPUS --mem $MEM --disk $DISCO $UBUNTUVER

# Transferir las llaves publicas a las instancias
$MULTIPASS transfer ~/.ssh/id_rsa.pub $MASTER:
$MULTIPASS transfer ~/.ssh/id_rsa.pub $WORKER1:
$MULTIPASS transfer ~/.ssh/id_rsa.pub $WORKER2:

# Agregarlas a las autorizadas
$MULTIPASS exec $MASTER -- bash -c 'sudo cat /home/ubuntu/id_rsa.pub >> .ssh/authorized_keys'
$MULTIPASS exec $WORKER1 -- bash -c 'sudo cat /home/ubuntu/id_rsa.pub >> .ssh/authorized_keys'
$MULTIPASS exec $WORKER2 -- bash -c 'sudo cat /home/ubuntu/id_rsa.pub >> .ssh/authorized_keys'

MASTERIP=`$MULTIPASS exec $MASTER -- bash -c 'ip -4 addr show eth0 | grep -oP "(?<=inet ).*(?=/)"'`
WORKER1IP=`$MULTIPASS exec $WORKER1 -- bash -c 'ip -4 addr show eth0 | grep -oP "(?<=inet ).*(?=/)"'`
WORKER2IP=`$MULTIPASS exec $WORKER2 -- bash -c 'ip -4 addr show eth0 | grep -oP "(?<=inet ).*(?=/)"'`

# Instalar el server
k3sup install --ip $MASTERIP --user ubuntu

#  export AGENT1_IP=192.168.0.101
#  export AGENT2_IP=192.168.0.101
#  export SERVER_IP=192.168.0.100
#  export USER=ubuntu

# Unir a los workers
k3sup join --ip $WORKER1IP --server-ip $MASTERIP --user $USER
k3sup join --ip $WORKER2IP --server-ip $MASTERIP --user $USER


# Test your cluster with:
echo "export KUBECONFIG=kubeconfig"
echo "kubectl get node -o wide"
