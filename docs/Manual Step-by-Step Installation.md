# Manual Step-by-Step Installation (Beginner Friendly)

This guide shows you, step by step, how to build and run everything from scratch. It’s written so a 7th grader can follow along.

What you’ll build:
- A special “base” image with CUDA 12.1 + Python 3.10 + PyTorch (GPU tools).
- Service images for mem0, bolna, and agents.
- Docker Compose stacks you can run on:
  - Ubuntu with GPUs
  - A laptop (no GPU)
  - A small cloud server (no GPU)

Helpful links to files in this project:
- Base Dockerfile: [docker/Dockerfile.base.py310.cu121](docker/Dockerfile.base.py310.cu121)
- Bolna Dockerfile: [docker/Dockerfile.bolna.dockerfile](docker/Dockerfile.bolna.dockerfile)
- mem0 Dockerfile: [docker/Dockerfile.mem0.dockerfile](docker/Dockerfile.mem0.dockerfile)
- Agents Dockerfile: [docker/Dockerfile.agents.dockerfile](docker/Dockerfile.agents.dockerfile)
- Ubuntu (GPU) Compose: [compose/docker-compose-ubuntu.yml](compose/docker-compose-ubuntu.yml)
- Laptop Compose: [compose/docker-compose-laptop.yml](compose/docker-compose-laptop.yml)
- Lightsail Compose: [compose/docker-compose-lightsail.yml](compose/docker-compose-lightsail.yml)
- Example env file: [configs/.env.example.txt](configs/.env.example.txt)

Before you start:
- Install Docker (Docker Desktop for Windows/macOS; Docker Engine for Ubuntu).
- If you will use GPUs on Ubuntu:
  - Install the NVIDIA GPU driver.
  - Install the NVIDIA Container Toolkit.
  - Run this on your Ubuntu host (not inside Docker) to make sure the driver works:
    - nvidia-smi

Step 1 — Make your settings file (.env):
- Copy the example file so you have your own settings:
  - cp configs/.env.example.txt configs/.env
- Open [configs/.env](configs/.env) in a text editor. Keep defaults if you don’t know what to change yet.
- By default, we choose the two RTX 3060 GPUs (IDs 2 and 3). You can change CUDA_VISIBLE_DEVICES later.

Step 2 — Create data folders (for Compose volumes):
Run these commands from the project folder:
- mkdir -p compose/n8n-data
- mkdir -p compose/ollama-models

Step 3 — Build the base image (GPU tools + Python):
- docker build -f [docker/Dockerfile.base.py310.cu121](docker/Dockerfile.base.py310.cu121) -t me2-base:py310-cu121 .

Step 4 — Build the service images (optional, but helpful first time):
- mem0:
  - docker build -f [docker/Dockerfile.mem0.dockerfile](docker/Dockerfile.mem0.dockerfile) -t compose-mem0 scripts
- bolna:
  - docker build -f [docker/Dockerfile.bolna.dockerfile](docker/Dockerfile.bolna.dockerfile) -t compose-bolna .
- agents:
  - docker build -f [docker/Dockerfile.agents.dockerfile](docker/Dockerfile.agents.dockerfile) -t compose-agents .

Step 5 — Choose a Compose stack and run it:
Only run one stack at a time. All commands run from the project folder.

- Ubuntu with GPU (uses GPUs 2 and 3 by default):
  - docker compose -f [compose/docker-compose-ubuntu.yml](compose/docker-compose-ubuntu.yml) up --build

- Laptop (no GPU):
  - docker compose -f [compose/docker-compose-laptop.yml](compose/docker-compose-laptop.yml) up --build

- Lightsail (cloud, no GPU):
  - docker compose -f [compose/docker-compose-lightsail.yml](compose/docker-compose-lightsail.yml) up --build

Step 6 — Open the apps:
- n8n
  - Ubuntu (GPU): http://localhost:5678
  - Laptop: http://127.0.0.1:5679
  - Lightsail: http://your-server-ip/
- mem0
  - Ubuntu (GPU): http://127.0.0.1:7777
  - Laptop: http://127.0.0.1:7778
  - Lightsail: http://your-server-ip:7777
- bolna (Ubuntu GPU only): http://127.0.0.1:8000
- agents (Ubuntu GPU only): http://127.0.0.1:5000

Tip: First startup can take 1–2 minutes. If a page doesn’t load, wait and refresh.

Step 7 — Check GPUs are set correctly (Ubuntu GPU stack):
- Validate compose file:
  - docker compose -f [compose/docker-compose-ubuntu.yml](compose/docker-compose-ubuntu.yml) config
- Start detached:
  - docker compose -f [compose/docker-compose-ubuntu.yml](compose/docker-compose-ubuntu.yml) up -d
- See which GPUs are visible inside containers (should show GPUs 2 and 3 by default):
  - docker compose -f [compose/docker-compose-ubuntu.yml](compose/docker-compose-ubuntu.yml) exec ollama nvidia-smi
  - docker compose -f [compose/docker-compose-ubuntu.yml](compose/docker-compose-ubuntu.yml) exec bolna nvidia-smi

To change which GPUs are used:
- Edit CUDA_VISIBLE_DEVICES in [configs/.env](configs/.env).
- Restart the Ubuntu stack.

Step 8 — Stop and start later:
- Stop (in the same stack you started):
  - Press Ctrl+C if it’s running in the foreground, then:
  - docker compose -f compose/docker-compose-<name>.yml down
- Start again:
  - docker compose -f compose/docker-compose-<name>.yml up --build

Troubleshooting:
- “Bolna module not found” (No module named bolna.server):
  - Follow the manual workaround to run from source inside the container: [docs/bolna-manual-workaround.md](docs/bolna-manual-workaround.md)
- “Port already in use”:
  - Change the port on the left side (e.g., 8000:8000 to 8001:8000) in your compose file.
- “GPU not found”:
  - On the host, make sure nvidia-smi works first. Install the NVIDIA driver and NVIDIA Container Toolkit.
- “.env file not found”:
  - Make sure you created [configs/.env](configs/.env) from [configs/.env.example.txt](configs/.env.example.txt).
- “Folder not found” for volumes:
  - Create folders inside compose/: [compose/n8n-data](compose/n8n-data) and [compose/ollama-models](compose/ollama-models).

Cheat sheet (copy/paste):
- Build base:
  - docker build -f [docker/Dockerfile.base.py310.cu121](docker/Dockerfile.base.py310.cu121) -t me2-base:py310-cu121 .
- Build services:
  - docker build -f [docker/Dockerfile.mem0.dockerfile](docker/Dockerfile.mem0.dockerfile) -t compose-mem0 scripts
  - docker build -f [docker/Dockerfile.bolna.dockerfile](docker/Dockerfile.bolna.dockerfile) -t compose-bolna .
  - docker build -f [docker/Dockerfile.agents.dockerfile](docker/Dockerfile.agents.dockerfile) -t compose-agents .
- Run Ubuntu GPU:
  - docker compose -f [compose/docker-compose-ubuntu.yml](compose/docker-compose-ubuntu.yml) up --build
- Check GPUs (Ubuntu GPU):
  - docker compose -f [compose/docker-compose-ubuntu.yml](compose/docker-compose-ubuntu.yml) exec ollama nvidia-smi
  - docker compose -f [compose/docker-compose-ubuntu.yml](compose/docker-compose-ubuntu.yml) exec bolna nvidia-smi

Notes for advanced users:
- Stable ENV defaults (CUDA_HOME, PATH, LD_LIBRARY_PATH, PYTHONPATH) are defined in [docker/Dockerfile.base.py310.cu121](docker/Dockerfile.base.py310.cu121).
- Runtime GPU selection is managed by CUDA_VISIBLE_DEVICES via [compose/docker-compose-ubuntu.yml](compose/docker-compose-ubuntu.yml) and [configs/.env](configs/.env).