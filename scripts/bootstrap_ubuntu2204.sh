#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] bootstrap_ubuntu2204.sh — streamlined one-command setup for Ubuntu 22.04/24.04"

. /etc/os-release
ID_LOWER="${ID:-ubuntu}"
VER="${VERSION_ID:-}"
if [[ "$ID_LOWER" != "ubuntu" ]]; then
  echo "[ERROR] Only Ubuntu supported. Detected: $ID_LOWER"
  exit 1
fi
if [[ "$VER" != "22.04" && "$VER" != "24.04" ]]; then
  echo "[WARN] Detected Ubuntu $VER; proceeding (script tuned for 22.04/24.04)."
fi

echo "[STEP] Installing core packages (docker, compose plugin, git, python3-pip, curl, gnupg, lsb-release, ca-certificates, snapd)..."
sudo apt update
sudo apt install -y docker.io docker-compose-plugin git python3-pip curl gnupg lsb-release ca-certificates snapd

echo "[STEP] Ensuring Node.js 20 via Snap (avoids APT GPG issues)..."
if ! command -v npm >/dev/null 2>&1; then
  sudo snap install node --channel=20/stable --classic
  sudo ln -sf /snap/bin/node /usr/local/bin/node || true
  sudo ln -sf /snap/bin/npm /usr/local/bin/npm || true
fi
node -v && npm -v

echo "[STEP] NVIDIA container toolkit setup (idempotent). Safe to run without GPU."
sudo bash "$(dirname "$0")/cleanup_ubuntu_nvidia.sh"

echo "[STEP] Adding current user to docker group (if not already)..."
if ! id -nG "$USER" | grep -qw docker; then
  sudo usermod -aG docker "$USER"
  echo "[NOTE] You must log out and back in (or 'newgrp docker') for group changes to take effect."
fi

echo "[STEP] Verifying docker and compose..."
docker --version
docker compose version

echo "[STEP] Ensuring env file exists..."
if [[ ! -f configs/.env ]]; then
  cp -n configs/.env.example.txt configs/.env || true
  echo "[NOTE] Created configs/.env from example. Edit it before first run if needed."
fi

echo "[STEP] Building and starting services..."
docker compose -f compose/docker-compose-ubuntu.yml up -d --build
docker compose -f compose/docker-compose-ubuntu.yml ps

echo "[DONE] Stack started. Tail logs with:"
echo "docker compose -f compose/docker-compose-ubuntu.yml logs -f n8n-local ollama mem0 agents"