#!/bin/bash

set -e  # Para o script em caso de erro

echo ".........----------------#################._.-.-INSTALL-.-._.#################----------------........."

# Configuração do prompt
PS1='\[\e[01;36m\]\u\[\e[01;37m\]@\[\e[01;33m\]\H\[\e[01;37m\]:\[\e[01;32m\]\w\[\e[01;37m\]\$\[\033[0;37m\] '
echo "PS1='$PS1'" >> ~/.bashrc
sed -i '1s/^/force_color_prompt=yes\n/' ~/.bashrc
source ~/.bashrc

# Atualização e remoção de pacotes desnecessários
sudo apt-get autoremove -y  
sudo apt-get update
sudo systemctl daemon-reload

# Adicionando chave do repositório Kubernetes (método atualizado)
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /etc/apt/keyrings/kubernetes-archive-keyring.gpg > /dev/null

# Adicionando repositório Kubernetes
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Definição da versão do Kubernetes
KUBE_VERSION=1.20.0

# Instalação de pacotes essenciais
sudo apt-get update
sudo apt-get install -y docker.io vim build-essential jq python3-pip \
    kubelet=${KUBE_VERSION}-00 kubectl=${KUBE_VERSION}-00 \
    kubernetes-cni=0.8.7-00 kubeadm=${KUBE_VERSION}-00

pip3 install jc

# UUID da VM (evita erro caso `dmidecode` não esteja disponível)
if command -v dmidecode &> /dev/null; then
    jc dmidecode | jq .[1].values.uuid -r
fi

# Configuração do Docker
sudo mkdir -p /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "storage-driver": "overlay2"
}
EOF

sudo mkdir -p /etc/systemd/system/docker.service.d
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker
sudo systemctl enable kubelet
sudo systemctl start kubelet

echo ".........----------------#################._.-.-KUBERNETES-.-._.#################----------------........."

# Reset Kubernetes antes da instalação (caso já tenha sido instalado antes)
sudo rm -rf /root/.kube/config
sudo kubeadm reset -f

# Instalação do cluster Kubernetes
sudo kubeadm init --kubernetes-version=${KUBE_VERSION} --skip-token-print

# Configuração do kubectl para o usuário atual
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Instalação do CNI (rede Kubernetes)
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

sleep 60  # Aguarde a configuração da rede

# Remover taints do nó para permitir agendamentos
echo "Removendo taints do nó de controle..."
kubectl taint node $(kubectl get nodes -o=jsonpath='{.items[0].metadata.name}') node-role.kubernetes.io/control-plane:NoSchedule- --overwrite=true
kubectl get nodes -o wide

echo ".........----------------#################._.-.-Java e MAVEN-.-._.#################----------------........."

# Instalação do Java e Maven
sudo apt install openjdk-11-jdk -y
java -version
sudo apt install -y maven
mvn -v

echo ".........----------------#################._.-.-JENKINS-.-._.#################----------------........."

# Adicionando chave do repositório do Jenkins (método atualizado)
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /etc/apt/keyrings/jenkins-keyring.asc > /dev/null

# Adicionando repositório do Jenkins
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list

# Instalação do Jenkins
sudo apt update
sudo apt install -y jenkins
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Adicionando Jenkins ao grupo Docker
sudo usermod -aG docker jenkins
echo "jenkins ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

echo ".........----------------#################._.-.-COMPLETED-.-._.#################----------------........."
