#!/bin/bash
#### scripts/setup_ubuntu.sh
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
# Install prerequisites
sudo apt update
sudo apt install -y docker.io docker-compose docker-compose-plugin git python3-pip curl gnupg lsb-release ca-certificates
# NVIDIA setup (abridged)
# Clean legacy NVIDIA Docker repos (if present)
sudo rm -f /etc/apt/sources.list.d/nvidia-docker.list /etc/apt/sources.list.d/nvidia-container-runtime.list /etc/apt/sources.list.d/libnvidia-container.list /etc/apt/sources.list.d/nvidia-container-toolkit.list || true

# Set up NVIDIA Container Toolkit repo with signed keyring (Ubuntu 22.04/24.04)
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
distribution=$(. /etc/os-release; echo $ID$VERSION_ID)
curl -fsSL https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null
sudo apt update
sudo apt install -y nvidia-container-toolkit
sudo systemctl restart docker

# Install Node.js 20.x (for npm) via NodeSource signed APT repo
. /etc/os-release
UBUNTU_CODENAME=${UBUNTU_CODENAME:-$(lsb_release -sc 2>/dev/null || echo noble)}
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/nodesource.gpg
echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x ${UBUNTU_CODENAME} main" | sudo tee /etc/apt/sources.list.d/nodesource.list > /dev/null
sudo apt update
sudo apt install -y nodejs
# Clone agent repos
git clone https://github.com/chatrouter/chatrouter
cd chatrouter && npm install
cd ..
git clone https://github.com/usestrix/strix
cd strix && pip install -r requirements.txt
cd ..
git clone https://github.com/Factory-AI/factory
cd factory && pip install -r requirements.txt
cd ..
git clone https://github.com/bolna-ai/bolna
cd bolna && pip install -r requirements.txt
cd ..
# Ollama
curl -fsSL https://ollama.com/install.sh | sh
echo "Setup complete."
echo "Next steps:"
echo "1) Create configs/.env from configs/.env.example.txt and add required keys"
echo "2) Build and start services:"
echo "   docker compose -f compose/docker-compose-ubuntu.yml up -d --build"