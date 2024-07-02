#!/bin/bash
set -e

# Update the package index
sudo apt-get update

# Install Docker
sudo apt-get install -y docker.io

# Enable and start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Install Kubernetes components
sudo apt-get install -y apt-transport-https curl gnupg2
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Enable and start Kubelet service
sudo systemctl enable kubelet
sudo systemctl start kubelet

# Disable swap (required by Kubernetes)
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Initialize Kubernetes on master node if needed
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Wait for kubeadm init to complete
sleep 240

# Set up local kubeconfig
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Apply Flannel CNI plugin
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Generate join command for worker nodes
sudo kubeadm token create --print-join-command > /joincluster.sh

# Make the join script executable
sudo chmod +x /joincluster.sh
