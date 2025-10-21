#### scripts/setup_ubuntu.sh
#!/bin/bash
Install prerequisites
sudo apt update
sudo apt install -y docker.io docker-compose git python3-pip nvidia-docker2
NVIDIA setup (abridged)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt update && sudo apt install -y nvidia-container-toolkit
sudo systemctl restart docker
Clone agent repos
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
Ollama
curl -fsSL https://ollama.com/install.sh | sh
echo "Setup complete. Edit .env and run docker-compose."