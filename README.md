# ME-2.0: Agentic AI Life Automation System (v1.1)

[![GitHub stars](https://img.shields.io/github/stars/yourusername/me-2.0?style=social)](https://github.com/yourusername/me-2.0/stargazers)
[![GitHub license](https://img.shields.io/github/license/yourusername/me-2.0)](https://github.com/yourusername/me-2.0/blob/main/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/yourusername/me-2.0)](https://github.com/yourusername/me-2.0/issues)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/yourusername/me-2.0/ci.yml)](https://github.com/yourusername/me-2.0/actions) <!-- Add a .github/workflows/ci.yml for actual CI -->
[![Docker Pulls](https://img.shields.io/docker/pulls/yourdockerhub/me-2.0?color=blue)](https://hub.docker.com/r/yourdockerhub/me-2.0) <!-- If you push images -->
[![Made with Grok](https://img.shields.io/badge/Made%20with-Grok%20by%20xAI-orange)](https://x.ai)

ME-2.0 is a fully autonomous, agentic AI system designed to take over your personal and professional life—handling everything from pentesting jobs to scheduling appointments, all in 24/7 Hands-Off Takeover (HOT) mode. Built as a hybrid swarm of AI agents that communicate, learn, and evolve, it leverages open-source tools for orchestration, memory, security, coding, and voice interactions. Inspired by futuristic autonomy (think Jarvis meets Tesla FSD), it's tailored to your hardware: Ubuntu GPU rig for compute muscle, Windows laptop for corporate mobility, and AWS Lightsail for cloud persistence.

## What is ME-2.0?
ME-2.0 is an open-source, hybrid AI framework that creates a digital clone of you—"ME 2.0"—using interconnected agents. Key features:
- **Agent Swarm**: Agents for pentesting (STRIX), coding (Factory AI), communication (ChatRouter), memory (Mem0), email (DreamLit), and voice (Twilio + Bolna).
- **Orchestration**: n8n workflows glue everything, enabling autonomous loops.
- **Hybrid Architecture**: Tri-node setup (local GPU rig, laptop edge, cloud hub) for resilience, privacy, and 24/7 uptime.
- **Learning & Autonomy**: Mem0 persists knowledge, allowing the system to "learn" your habits and predict needs.
- **Voice Integration**: Handles calls, schedules, and reminders via natural language.

It's not just automation—it's a self-evolving AI ecosystem, versioned at 1.1 with room for expansions (e.g., more agents via Factory AI).

## Why ME-2.0?
Traditional automation tools are siloed and manual. ME-2.0 stands out with:
- **Distributed Resilience**: No single point of failure—laptop for on-the-go corporate tasks, GPU rig for heavy local compute (privacy-sensitive pentests), cloud for always-on persistence. Why? Balances cost, security, and availability (e.g., your 64GB RAM + 5 GPUs crush local LLMs without API bills).
- **Agentic Intelligence**: Agents "talk" via ChatRouter, share memory with Mem0, and run HOT loops. Why? Enables emergent behaviors, like auto-generating code for new features or auditing itself with STRIX.
- **Hybrid & Customizable**: Local (Ollama LLMs on GPUs), API-driven (Twilio for voice), cloud-scaled (Lightsail). Why? Avoids vendor lock-in, optimizes for your Z270 rig (GPU passthrough via NVIDIA Docker) and ThinkPad (lightweight Docker Desktop).
- **Security-First**: STRIX self-audits, data partitioned (corp on laptop via Zscaler VPN). Why? Your role as VPN admin makes it seamless for pro/personal separation.
- **Cost-Effective & Scalable**: Starts free/local, scales to ~$5/mo cloud. Why? Leverages your hardware for efficiency, with env vars for easy tweaks.

In short: It's built for real-world takeover, not toy demos—iterative, phased, and evolvable like SpaceX projects.

## Use Cases
ME-2.0 shines in automating chaotic lives. Examples:
1. **Professional Pentesting Workflow**: Inbound email (DreamLit) triggers STRIX on your GPU rig for vuln scans, Factory AI generates reports/scripts, Mem0 logs findings. Use case: As a security pro, let it handle routine jobs 24/7, notifying via voice (Twilio) for escalations—frees you for strategy.
2. **Personal Scheduling & Calls**: Voice agent (Bolna + Twilio) answers calls, books appointments (Google Calendar API), reminds via outbound calls. Use case: "Hey ME, schedule dentist"—it checks conflicts, confirms, stores prefs in Mem0. Ideal for busy folks avoiding apps.
3. **Daily HOT Automation**: Cron workflows check emails, run code fixes (Factory AI), pentest queues (STRIX), and voice summaries. Use case: Wake up to a "day takeover" report—personal (grocery lists) + pro (code reviews), evolving via learned habits.
4. **Hybrid On-the-Go**: Laptop node handles corp tasks (VPN-isolated), syncs to cloud. Use case: Travel? System runs uninterrupted, with failover to Lightsail if rig powers down.
5. **Self-Evolving System**: Agents code new features on-demand (e.g., add finance bot). Use case: Start simple, grow to full life mgmt—research, shopping, even creative tasks.

## Installation & Setup
### Agent Frameworks Installation

ME-2.0 integrates three agent frameworks that are not available on PyPI: [Strix](https://github.com/usestrix/strix) (pentesting), [Factory AI](https://github.com/Factory-AI/factory) (coding), and [ChatRouter](https://github.com/chatrouter/chatrouter) (communication). These frameworks are installed using two complementary approaches depending on your use case:

#### Production Approach (Build-Time Installation)

The production approach installs frameworks directly into the Docker image during the build process. This is implemented in [`docker/Dockerfile.agents.dockerfile`](docker/Dockerfile.agents.dockerfile:1) and provides:

**Advantages:**
- **Self-contained images**: All dependencies bundled, ready to deploy anywhere
- **Reproducible builds**: Same image works identically across all nodes
- **Faster container startup**: No volume mount overhead
- **Cleaner deployment**: No host dependencies required

**Implementation Details:**
```dockerfile
# Install git for cloning agent frameworks
RUN apt-get update && apt-get install -y --no-install-recommends git && rm -rf /var/lib/apt/lists/*

# Clone repos to /tmp, install, then clean up
RUN cd /tmp && \
    git clone https://github.com/usestrix/strix && \
    cd strix && pip install --no-cache-dir . && \
    cd /tmp && \
    git clone https://github.com/Factory-AI/factory && \
    cd factory && pip install --no-cache-dir . && \
    cd /tmp && \
    git clone https://github.com/chatrouter/chatrouter && \
    cd chatrouter && pip install --no-cache-dir . && \
    cd / && rm -rf /tmp/strix /tmp/factory /tmp/chatrouter
```

**When to Use:**
- Deploying to cloud (AWS Lightsail) where you want immutable infrastructure
- Production workloads requiring stability and reproducibility
- When you need to share images across teams or environments
- For CI/CD pipelines where consistency is critical

**Version Pinning:**
To pin specific commits for reproducibility, modify the clone commands:
```dockerfile
git clone https://github.com/usestrix/strix && cd strix && git checkout <commit-hash> && pip install .
```

#### Development Approach (Volume Mount Installation)

The development approach uses volume mounts to make locally-cloned repositories available to containers. This is configured in [`compose/docker-compose-ubuntu.yml`](compose/docker-compose-ubuntu.yml:28) via:

```yaml
volumes:
  - ../scripts:/app/scripts  # Host-cloned repos mounted here
```

**Advantages:**
- **Live code editing**: Changes to framework code immediately available in containers
- **Rapid iteration**: No image rebuild required for testing modifications
- **Easy debugging**: Can add print statements, breakpoints directly in framework code
- **Framework development**: Ideal when contributing back to Strix/Factory/ChatRouter

**Implementation Steps:**
1. Clone frameworks to your host machine outside the ME-2.0 repo:
   ```bash
   cd ~/projects  # Or your preferred location
   git clone https://github.com/usestrix/strix
   git clone https://github.com/Factory-AI/factory
   git clone https://github.com/chatrouter/chatrouter
   ```

2. Install in development mode (editable installs):
   ```bash
   cd ~/projects/strix && pip install -e .
   cd ~/projects/factory && pip install -e .
   cd ~/projects/chatrouter && pip install -e .
   ```

3. Update compose file to mount these directories:
   ```yaml
   volumes:
     - ~/projects/strix:/app/strix
     - ~/projects/factory:/app/factory
     - ~/projects/chatrouter:/app/chatrouter
   ```

4. Restart containers to pick up changes:
   ```bash
   docker compose -f compose/docker-compose-ubuntu.yml restart agents
   ```

**When to Use:**
- Active development on agent frameworks
- Testing experimental features before committing
- Debugging framework-specific issues
- Contributing patches back to upstream repos

#### Hybrid Strategy (Recommended)

For maximum flexibility, use **both approaches**:

1. **Base Image (Production)**: Build [`Dockerfile.agents.dockerfile`](docker/Dockerfile.agents.dockerfile:1) with frameworks pre-installed for stability
2. **Development Override**: Add volume mounts in local compose files to override with editable versions when needed
3. **Switch Seamlessly**: Remove volume mounts to revert to production build without image changes

Example local override in `docker-compose.override.yml`:
```yaml
services:
  agents:
    volumes:
      - ~/projects/strix:/app/strix  # Override with local dev version
      # Comment out to use production build version
```

#### Troubleshooting

**Build Failures:**

*Problem: Git clone fails during Docker build*
```
fatal: unable to access 'https://github.com/usestrix/strix/': Could not resolve host
```
**Solution:** Check network connectivity. If behind corporate proxy, add proxy settings to Dockerfile:
```dockerfile
ENV http_proxy=http://proxy.corp.com:8080
ENV https_proxy=http://proxy.corp.com:8080
```

*Problem: Pip install fails with missing dependencies*
```
ERROR: Could not find a version that satisfies the requirement <package>
```
**Solution:** Some frameworks have unlisted dependencies. Install manually before framework:
```dockerfile
RUN pip install --no-cache-dir <missing-package>
```

*Problem: Image size bloated after installs*
```
REPOSITORY          TAG       SIZE
me-2.0-agents      latest    2.5GB
```
**Solution:** Ensure cleanup runs in same RUN layer (already implemented):
```dockerfile
RUN cd /tmp && git clone ... && pip install . && cd / && rm -rf /tmp/*
```

**Runtime Issues:**

*Problem: ImportError for framework modules*
```python
ModuleNotFoundError: No module named 'strix'
```
**Solution:** Verify installation in container:
```bash
docker exec -it agents-container pip list | grep strix
```
If missing, rebuild image: `docker compose build --no-cache agents`

*Problem: Volume mount shows old code despite local changes*
**Solution:** Restart container to refresh mounts:
```bash
docker compose restart agents
```
Or force recreate: `docker compose up -d --force-recreate agents`

*Problem: Permission denied accessing mounted framework directories*
```
PermissionError: [Errno 13] Permission denied: '/app/strix/...'
```
**Solution:** Fix ownership on host:
```bash
sudo chown -R $(id -u):$(id -g) ~/projects/strix ~/projects/factory ~/projects/chatrouter
```

**Version Conflicts:**

*Problem: Frameworks require conflicting dependency versions*
```
ERROR: pip's dependency resolver does not currently take into account all the packages that are installed
```
**Solution:** Create separate containers per framework or use virtual environments within container. Alternatively, pin compatible versions in a requirements.txt added to Dockerfile.

**Debugging Tips:**
- **Check installed versions**: `docker exec agents-container pip show strix factory chatrouter`
- **View build logs**: `docker compose build agents 2>&1 | tee build.log`
- **Test framework imports**: `docker exec agents-container python -c "import strix; print(strix.__version__)"`
- **Compare prod vs dev**: Use `docker diff` to see filesystem changes between image and container with mounts

**Getting Help:**
- Framework-specific issues: Check GitHub issues for [Strix](https://github.com/usestrix/strix/issues), [Factory AI](https://github.com/Factory-AI/factory/issues), [ChatRouter](https://github.com/chatrouter/chatrouter/issues)
- ME-2.0 integration problems: Open issue on this repo with build logs and environment details
- Docker build failures: Review [Docker documentation](https://docs.docker.com/engine/reference/builder/) for Dockerfile best practices

Clone the repo and bootstrap per node. Requirements: Git, Docker (with NVIDIA support on Ubuntu), Python 3.12+.
```
me-2.0/
├── README.md
├── docker/
│   ├── Dockerfile.mem0
│   ├── Dockerfile.bolna
│   └── Dockerfile.agents  # Custom for STRIX/Factory AI/ChatRouter
├── scripts/
│   ├── setup_ubuntu.sh  # Bash for Ubuntu rig
│   ├── setup_laptop.ps1  # PowerShell for Windows laptop
│   ├── run_mem0.py
│   └── agent_orchestrator.py  # Python for basic agent comms test
├── compose/
│   ├── docker-compose-ubuntu.yml  # For local rig
│   ├── docker-compose-laptop.yml  # For ThinkPad
│   └── docker-compose-lightsail.yml  # For cloud (adapt via SSH)
├── configs/
│   ├── .env.example  # Template for env vars
│   └── n8n-workflows/  # Dir for exported JSON workflows
│       └── basic-voice-schedule.json
├── docs/  # From previous, updated for v1.1
│   ├── architecture.md
│   ├── implementation.md
│   └── admin-guides.md
├── diagrams/
│   └── architecture-diagram.puml
└── version-control/
└── changelog.md  # Updated for v1.1
```

### 1. Clone and Prepare
```bash
git clone https://github.com/yourusername/me-2.0.git
cd me-2.0
cp configs/.env.example .env
```

### 2. Node-Specific Installs
```
Ubuntu GPU Rig (Local Compute Heavy)
Your Z270 setup with 64GB RAM + GPUs. Focus: GPU passthrough for Ollama/agents.

Run setup script: ./scripts/setup_ubuntu.sh (installs Docker, NVIDIA toolkit, clones repos).
Env Vars in .env:

TWILIO_*: For voice.
OLLAMA_MODEL: Default LLM (e.g., llama3).
NVIDIA_VISIBLE_DEVICES=all: For full GPU access (add to .env, reference in compose).
MEM0_DB_PATH=/path/to/persistent/db: For Mem0 state (volume mount).


Standout Config: Enable GPU reservations in docker-compose-ubuntu.yml for optimized inference (e.g., RTX 3060s for fast pentests).
Launch: docker compose -f compose/docker-compose-ubuntu.yml up -d --build
Tips: Use volumes for persistence (./ollama-models:/root/.ollama). Scale GPUs: Edit deploy.resources in yml for selective cards (e.g., reserve GTX 1060s for backups).

Windows Laptop (Corporate Edge – ThinkPad L14 Gen5)
Lightweight for mobility, integrates with Zscaler VPN.

Run setup script: powershell -File scripts/setup_laptop.ps1 (clones repos, assumes Docker Desktop).
Env Vars in .env:

Same as above, plus ZSCALER_VPN_ENABLED=true: Custom flag for VPN workflows (add If node in n8n).
TWILIO_PHONE_NUMBER: Your inbound number.


Standout Config: Use WSL for heavy Pip installs if Docker hits limits; env for port remapping (e.g., N8N_PORT=5679 to avoid conflicts).
Launch: docker compose -f compose/docker-compose-laptop.yml up -d --build
Tips: For corp isolation, mount VPN certs as volumes (./vpn-certs:/certs). Test with docker ps—keeps RAM low (your 16GB handles it).

AWS Lightsail (Cloud Hub)
For 24/7 persistence. Start with Nano instance (Ubuntu).

SSH in: Copy compose/docker-compose-lightsail.yml and .env.
Install Docker: sudo apt update && sudo apt install -y docker.io docker-compose
Env Vars in .env:

AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY: For integrations (optional).
MEM0_API_KEY: If using hosted Mem0 (fallback).


Standout Config: Add NGINX proxy in yml for SSL (image: nginx, volumes for certs). Use env for auto-scaling (e.g., LIGHTSAIL_INSTANCE_SIZE=nano—scriptable upgrades).
Launch: docker compose up -d --build
Tips: Monitor with CloudWatch (env: AWS_REGION=us-east-1). Failover: Webhook URLs point here for redundancy. # Edit with your keys (e.g., TWILIO_ACCOUNT_SID, OLLAMA_MODEL=llama3)
```

### 3. Common Configurations
```
Secrets Management: Use Docker secrets for sensitive envs (e.g., in compose: secrets: twilio_sid from file). Why? Standout security—avoids plaintext .env in prod.
Volumes & Persistence: Always mount data dirs (e.g., n8n workflows, Mem0 DB) to avoid loss on restarts.
Variables for Customization:

HOT_MODE_ENABLED=true: Enables 24/7 crons in n8n.
AGENT_DEBUG_LEVEL=verbose: Logs agent comms (ChatRouter/STRIX).
VOICE_TRANSCRIBE_MODEL=whisper: Switches to OpenAI API for accuracy.


Hybrid Sync: In n8n, use HTTP nodes with env ${CLOUD_WEBHOOK_URL} for cross-node pings.
Testing Setup: Run python scripts/agent_orchestrator.py for quick agent tests.
```

### Running ME-2.0
```
Import workflows: In n8n UI (e.g., localhost:5678), import configs/n8n-workflows/*.json.
HOT Mode: Activate workflows—system runs autonomously.
Voice Test: Call your Twilio number; watch logs.
Scale: Add agents by cloning repos into /app volumes.
```

### Contributing
```
Fork, branch (e.g., feature/new-agent), PR. Follow phased approach in docs/. Issues welcome!
```

### License
```
MIT License—free to hack and deploy. See LICENSE.
Built with 🚀 by Grok (in Elon mode). Let's make ME-2.0 unstoppable—star the repo and contribute!
```