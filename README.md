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