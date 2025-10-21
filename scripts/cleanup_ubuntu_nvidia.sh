#!/usr/bin/env bash
set -euo pipefail

# cleanup_ubuntu_nvidia.sh — Clean legacy NVIDIA apt entries and set up modern toolkit (Ubuntu 22.04/24.04),
# ensure Node.js/npm and Docker Compose plugin are available.
# Usage: sudo bash scripts/cleanup_ubuntu_nvidia.sh

if [[ $EUID -ne 0 ]]; then
  echo "Please run as root: sudo bash $0"
  exit 1
fi

echo "[INFO] Detecting OS..."
. /etc/os-release
ID_LOWER="${ID:-ubuntu}"
VERSION_ID_STR="${VERSION_ID:-}"
if [[ "$ID_LOWER" != "ubuntu" ]]; then
  echo "[ERROR] This script supports Ubuntu only. Detected: ${ID_LOWER}"
  exit 1
fi
if [[ "$VERSION_ID_STR" != "22.04" && "$VERSION_ID_STR" != "24.04" ]]; then
  echo "[WARN] Detected Ubuntu ${VERSION_ID_STR}. Proceeding, but script is tuned for 22.04/24.04."
fi
DISTRO="${ID_LOWER}${VERSION_ID_STR}"

echo "[STEP] Removing legacy NVIDIA APT source entries..."
rm -f /etc/apt/sources.list.d/nvidia-docker.list \
      /etc/apt/sources.list.d/nvidia-container-runtime.list \
      /etc/apt/sources.list.d/libnvidia-container.list \
      /etc/apt/sources.list.d/nvidia-container-toolkit.list || true

# Remove any leftover nvidia.github.io lines (e.g., ubuntu18.04) in apt lists
for f in /etc/apt/sources.list /etc/apt/sources.list.d/*.list; do
  if [[ -f "$f" ]] && grep -q "nvidia.github.io" "$f"; then
    echo "[INFO] Cleaning $f"
    sed -i.bak '/nvidia.github.io/d' "$f"
  fi
done

echo "[STEP] Installing NVIDIA Container Toolkit repo keyring..."
install -d -m 0755 /usr/share/keyrings
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

echo "[STEP] Adding NVIDIA Container Toolkit APT source for ${DISTRO}..."
curl -fsSL "https://nvidia.github.io/libnvidia-container/${DISTRO}/libnvidia-container.list" | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' > /etc/apt/sources.list.d/nvidia-container-toolkit.list

echo "[STEP] Refreshing apt and installing nvidia-container-toolkit..."
apt update
apt install -y nvidia-container-toolkit

echo "[STEP] Configuring Docker runtime for NVIDIA (if available)..."
if command -v nvidia-ctk >/dev/null 2>&1; then
  nvidia-ctk runtime configure --runtime=docker || true
else
  echo "[INFO] nvidia-ctk not found (older package). Skipping runtime configure."
fi
systemctl restart docker

echo "[STEP] Ensuring Docker Compose plugin is installed..."
if ! docker compose version >/dev/null 2>&1; then
  apt install -y docker-compose-plugin
fi

echo "[STEP] Ensuring Node.js 20 (npm) is installed..."
if ! command -v npm >/dev/null 2>&1; then
  # Determine Ubuntu codename (22.04=jammy, 24.04=noble)
  CODENAME="${UBUNTU_CODENAME:-$(lsb_release -sc 2>/dev/null || echo jammy)}"

  echo "[INFO] Cleaning any stale NodeSource entries and keys..."
  rm -f /etc/apt/sources.list.d/nodesource.list || true
  sed -i.bak '/deb\.nodesource\.com/d' /etc/apt/sources.list 2>/dev/null || true
  sed -i.bak '/deb\.nodesource\.com/d' /etc/apt/sources.list.d/*.list 2>/dev/null || true
  rm -f /usr/share/keyrings/nodesource.gpg || true

  echo "[STEP] Adding NodeSource signed keyring and APT source for ${CODENAME}..."
  install -d -m 0755 /usr/share/keyrings
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /usr/share/keyrings/nodesource.gpg
  echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x ${CODENAME} main" > /etc/apt/sources.list.d/nodesource.list

  echo "[STEP] Installing nodejs from NodeSource (with fallback to Snap if needed)..."
  apt update || true
  if ! apt install -y nodejs; then
    echo "[WARN] NodeSource install failed (possibly due to keyring/network). Falling back to Snap channel 20."
    if ! command -v snap >/dev/null 2>&1; then
      apt install -y snapd
    fi
    snap install node --channel=20/stable --classic
    ln -sf /snap/bin/node /usr/local/bin/node || true
    ln -sf /snap/bin/npm /usr/local/bin/npm || true
  fi
fi

echo "[VERIFY] Versions:"
docker --version || true
docker compose version || true
node -v || true
npm -v || true

echo
echo "[DONE] Cleanup and environment setup complete for Ubuntu ${VERSION_ID_STR}."
echo "Next steps (run as your normal user):"
echo "  cd ~/repos/ME-2.0"
echo "  docker compose -f compose/docker-compose-ubuntu.yml up -d --build"
echo "  docker compose -f compose/docker-compose-ubuntu.yml ps"
echo "  docker compose -f compose/docker-compose-ubuntu.yml logs -f n8n-local ollama mem0 agents"