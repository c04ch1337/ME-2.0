Below are friendly, step-by-step instructions that anyone can follow to build all images “from scratch” and run each Docker Compose stack. You’ll do this once per computer. Follow the order carefully and don’t skip steps.

Before you start
- You need Docker installed:
  - Windows or macOS: install Docker Desktop.
  - Ubuntu (Linux): install Docker Engine.
- If you will use the Ubuntu GPU stack:
  - Your computer must have an NVIDIA GPU.
  - Install the NVIDIA GPU driver and the NVIDIA Container Toolkit (lets Docker use the GPU).
- Open the project folder in your terminal (Command Prompt/PowerShell/Terminal) so your working directory is the ME-2.0 folder (the one that contains the compose and docker folders).

1) Make the .env file (settings)
- Find the example file: [configs/.env.example.txt](configs/.env.example.txt)
- Copy it to a new file named: [configs/.env](configs/.env)
- Open [configs/.env](configs/.env) and put in any keys or secrets you have. If you don’t have any yet, you can leave defaults for now.

2) Create the two folders that Compose uses to store data
- Make a folder named n8n-data next to your compose files (in the compose folder’s parent, which is the project root).
- Make a folder named ollama-models next to your compose files (in the project root).
Why? These folders are listed in the compose files for saving data:
- n8n uses n8n-data
- ollama uses ollama-models

3) Build the special base image (do this FIRST, one time)
This gives you the CUDA 12.1 + Python 3.10 + PyTorch stack that the bolna image uses.
- In your terminal, run:
  - docker build -f docker/Dockerfile.base.py310.cu121 -t me2-base:py310-cu121 .
- This uses [docker/Dockerfile.base.py310.cu121](docker/Dockerfile.base.py310.cu121) and creates a local image tag me2-base:py310-cu121.

4) Build each app image from scratch (optional but recommended the first time)
You can let docker compose build them automatically later, but building now makes problems easier to see.

- Build mem0 image (uses [docker/Dockerfile.mem0.dockerfile](docker/Dockerfile.mem0.dockerfile)):
  - docker build -f docker/Dockerfile.mem0.dockerfile -t compose-mem0 scripts
  - Note: scripts at the end is the build context. Keep it exactly like that.

- Build bolna image (uses [docker/Dockerfile.bolna.dockerfile](docker/Dockerfile.bolna.dockerfile)):
  - docker build -f docker/Dockerfile.bolna.dockerfile -t compose-bolna .

- Build agents image (uses [docker/Dockerfile.agents.dockerfile](docker/Dockerfile.agents.dockerfile)):
  - docker build -f docker/Dockerfile.agents.dockerfile -t compose-agents .

You don’t need to build n8n or ollama; those come from Docker Hub (pre-built).

5) Choose which Docker Compose stack you want to run
There are three different compose files. You can run whichever one matches your computer.

- Ubuntu GPU stack (for a Linux machine with an NVIDIA GPU)
  - File: [compose/docker-compose-ubuntu.yml](compose/docker-compose-ubuntu.yml)
  - What it includes: n8n, ollama (GPU), mem0, bolna, agents

- Laptop stack (for a local laptop with no GPU)
  - File: [compose/docker-compose-laptop.yml](compose/docker-compose-laptop.yml)
  - What it includes: n8n, mem0 (smaller setup)

- Lightsail stack (for a simple cloud server on AWS Lightsail, no GPU)
  - File: [compose/docker-compose-lightsail.yml](compose/docker-compose-lightsail.yml)
  - What it includes: n8n, mem0

6) Start the stack you picked (this will also build images if you skipped step 4)
Run one of these commands from the project folder (where the compose folder is). Only run one stack at a time.

- Ubuntu GPU stack:
  - docker compose -f compose/docker-compose-ubuntu.yml up --build
  - Tip (Linux GPU hosts): make sure the NVIDIA driver and nvidia-container-toolkit are installed before this. If you see GPU errors, fix those first.

- Laptop stack:
  - docker compose -f compose/docker-compose-laptop.yml up --build

- Lightsail stack (run this on your cloud VM after copying the project there):
  - docker compose -f compose/docker-compose-lightsail.yml up --build

Let the logs run. Services may take a minute to initialize. Health checks are built in, so they will retry if needed.

7) How to check if it’s working
- n8n:
  - Ubuntu stack: open http://localhost:5678
  - Laptop stack: open http://127.0.0.1:5679
  - Lightsail stack: open http://your-server-ip/ (port 80 maps to 5678)
- mem0:
  - Ubuntu stack: port 7777 (http://127.0.0.1:7777)
  - Laptop stack: port 7778 (http://127.0.0.1:7778)
  - Lightsail stack: port 7777 (http://your-server-ip:7777)
- bolna (only in Ubuntu GPU stack): http://127.0.0.1:8000
- agents (only in Ubuntu GPU stack): http://127.0.0.1:5000

If a page doesn’t open right away, give it ~1–2 minutes, then refresh.

8) Stopping and starting later
- To stop everything running in a stack:
  - Press Ctrl+C in the terminal where it’s running, then:
  - docker compose -f compose/docker-compose-<name>.yml down
- To start again later:
  - docker compose -f compose/docker-compose-<name>.yml up --build

9) Common problems and simple fixes
- “Port already in use” error:
  - Something else is using that port. Close the other app, or change the left side of the port mapping in the compose file you’re using (for example, change 8000:8000 to 8001:8000).
- “GPU not found” or “NVIDIA runtime” errors on Ubuntu GPU stack:
  - Make sure you installed the NVIDIA driver and the NVIDIA Container Toolkit.
  - If you don’t have a GPU, use the Laptop or Lightsail stack instead.
- “.env file not found”:
  - Make sure [configs/.env](configs/.env) exists (copy it from [configs/.env.example.txt](configs/.env.example.txt)).
- “Folder not found” for volumes:
  - Create the folders n8n-data and ollama-models in the project root (next to the compose and docker folders).

Quick reference: what each compose file does
- [compose/docker-compose-ubuntu.yml](compose/docker-compose-ubuntu.yml)
  - Builds from [docker/Dockerfile.mem0.dockerfile](docker/Dockerfile.mem0.dockerfile), [docker/Dockerfile.bolna.dockerfile](docker/Dockerfile.bolna.dockerfile), [docker/Dockerfile.agents.dockerfile](docker/Dockerfile.agents.dockerfile)
  - Pulls pre-built images for n8n and ollama
- [compose/docker-compose-laptop.yml](compose/docker-compose-laptop.yml)
  - Builds from [docker/Dockerfile.mem0.dockerfile](docker/Dockerfile.mem0.dockerfile)
  - Pulls pre-built image for n8n
- [compose/docker-compose-lightsail.yml](compose/docker-compose-lightsail.yml)
  - Builds from [docker/Dockerfile.mem0.dockerfile](docker/Dockerfile.mem0.dockerfile)
  - Pulls pre-built image for n8n

Manual build commands (if you ever want to rebuild from scratch)
- Base image (required for bolna):
  - docker build -f docker/Dockerfile.base.py310.cu121 -t me2-base:py310-cu121 .
- App images:
  - mem0: docker build -f docker/Dockerfile.mem0.dockerfile -t compose-mem0 scripts
  - bolna: docker build -f docker/Dockerfile.bolna.dockerfile -t compose-bolna .
  - agents: docker build -f docker/Dockerfile.agents.dockerfile -t compose-agents .

That’s it. Follow these steps in order and you will build and run every image for each compose file from scratch, even on a fresh computer.