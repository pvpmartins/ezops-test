#!/bin/bash

# Update the package index
sudo apt-get update

# Install Docker
sudo apt-get install -y docker.io

# Enable Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Install Kubernetes components
sudo apt-get install -y apt-transport-https curl gnupg2
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

# Disable swap (required by Kubernetes)
sudo swapoff -a

# Initialize Kubernetes on master node if needed
if hostname | grep -q "master"; then
  sudo kubeadm init --pod-network-cidr=10.244.0.0/16

  # Set up local kubeconfig
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

  # Apply Flannel CNI plugin or your preferred CNI plugin
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

  # Generate join command for worker nodes
  kubeadm token create --print-join-command > /joincluster.sh
fi

