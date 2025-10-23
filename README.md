#!/bin/bash
# ==========================================================
# DevOps Environment Setup Script for Ubuntu
# Tested on Ubuntu 20.04 / 22.04 / 24.04
# ==========================================================

LOGFILE="devops_setup.log"
exec > >(tee -i $LOGFILE)
exec 2>&1

echo "=========================================="
echo "🚀 Starting DevOps Environment Setup"
echo "=========================================="
sleep 2

# --- Update System ---
echo "[1/20] Updating system..."
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y build-essential curl wget unzip git apt-transport-https ca-certificates gnupg lsb-release software-properties-common

# --- Git & GitHub CLI ---
echo "[2/20] Installing Git & GitHub CLI..."
sudo apt install -y git git-lfs
if ! command -v gh &> /dev/null; then
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update && sudo apt install -y gh
fi

# --- Docker ---
echo "[3/20] Installing Docker..."
sudo apt remove docker docker-engine docker.io containerd runc -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

# --- Kubernetes (kubectl + minikube + helm) ---
echo "[4/20] Installing Kubernetes tools..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt update && sudo apt install -y helm

# --- Terraform ---
echo "[5/20] Installing Terraform..."
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform

# --- Ansible ---
echo "[6/20] Installing Ansible..."
sudo apt install -y ansible

# --- Jenkins ---
echo "[7/20] Installing Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y openjdk-17-jdk jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# --- AWS CLI ---
echo "[8/20] Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws/

# --- Azure CLI ---
echo "[9/20] Installing Azure CLI..."
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# --- Google Cloud CLI ---
echo "[10/20] Installing Google Cloud CLI..."
sudo apt-get install -y apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
  sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt update && sudo apt install -y google-cloud-sdk

# --- HashiCorp Vault ---
echo "[11/20] Installing Vault..."
sudo apt install -y vault

# --- Monitoring Tools ---
echo "[12/20] Installing Prometheus & Grafana..."
sudo apt install -y prometheus grafana

# --- Programming Languages ---
echo "[13/20] Installing Python, Node.js & Go..."
sudo apt install -y python3 python3-pip nodejs npm golang-go

# --- Networking & Debugging Tools ---
echo "[14/20] Installing Network & System Tools..."
sudo apt install -y net-tools nmap telnet traceroute dnsutils jq htop iotop iftop tree vim tmux

# --- Nomad & Consul ---
echo "[15/20] Installing Nomad & Consul..."
sudo apt install -y nomad consul

# --- Optional Tools ---
echo "[16/20] Installing Vagrant & Podman..."
sudo apt install -y vagrant podman

# --- Cleanup ---
echo "[17/20] Cleaning up unused packages..."
sudo apt autoremove -y && sudo apt clean

# --- Verification ---
echo "[18/20] Verifying installations..."
for tool in docker kubectl terraform ansible aws helm jenkins git; do
  if command -v $tool &> /dev/null; then
    echo "✅ $tool installed successfully"
  else
    echo "❌ $tool installation failed"
  fi
done

echo "[19/20] Enabling required services..."
sudo systemctl enable docker
sudo systemctl enable jenkins

echo "[20/20] DevOps setup completed successfully 🎉"
echo "Reboot your system for Docker group permissions to take effect."
echo "=========================================="
echo "✅ Log saved to: $LOGFILE"
echo "=========================================="
