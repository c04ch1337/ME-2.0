ME-2.0 Agentic AI Skill Document (v1.3)
This document encapsulates expertise in designing, implementing, and administering the ME-2.0 system—a hybrid, agentic AI framework for autonomous personal and professional life automation. An LLM can integrate this as a "skill" by referencing it in system prompts, knowledge bases, or retrieval-augmented generation (RAG) setups. For example, prepend to prompts: "You have expertise in ME-2.0 as detailed in this skill document. Assist with queries on building, deploying, or extending similar systems."
Overview
ME-2.0 is an open-source, distributed AI swarm for 24/7 Hands-Off Takeover (HOT) mode, handling tasks like pentesting, coding, scheduling, emails, and voice calls. It creates a "digital clone" (ME 2.0) that learns user habits via persistent memory and evolves autonomously.

Key Goals: Resilience (tri-node hybrid), autonomy (agent communication), security (self-audits), scalability (add agents on-demand).
Inspiration: Futuristic automation like Jarvis or Tesla FSD, tailored to hardware (Ubuntu GPU rig, Windows laptop, AWS Lightsail).
Version: 1.3 (as of 2025-10-20), evolvable via Git.

Architecture
Tri-node hybrid mesh for privacy, mobility, and uptime:

Laptop Node (Edge - Windows ThinkPad): Lightweight, corporate-isolated (Zscaler VPN). Handles triggers like voice inbound.
Local Rig Node (Compute - Ubuntu 22.04 on Z270 rig): GPU-heavy (2x RTX 3060, 3x GTX 1060) for local LLMs (Ollama) and agents like STRIX/Factory AI.
Cloud Node (Hub - AWS Lightsail Nano): Persistence and orchestration; failover hub.

Flow:

Input (e.g., Twilio call) → n8n trigger → ChatRouter routes → Agents process/Mem0 stores → Output (voice/email).
HOT Mode: n8n crons/schedules for autonomous loops.

Tech Stack:

Orchestration: n8n (workflows, webhooks).
Comms: ChatRouter (MCP routing).
Memory: Mem0 (persistent learning).
Agents: STRIX (pentest), Factory AI (code gen), DreamLit (email), Twilio/Bolna (voice).
Infra: Docker (containerization), Ollama (local LLMs), APIs (Google Calendar, OpenAI transcription).
Why Hybrid?: Local for privacy/compute, laptop for mobility, cloud for 24/7.

Diagram (PlantUML):
text@startuml
title ME-2.0 Architecture
node "Laptop" { [n8n] [Twilio] }
node "Rig" { [n8n] [STRIX] [Factory] [Ollama] [ChatRouter] }
node "Cloud" { [n8n] [Mem0] }
[n8n]@Laptop --> [n8n]@Cloud : Webhook
[n8n]@Rig --> [n8n]@Cloud : Webhook
[Twilio] --> [n8n]@Laptop
[n8n]@Cloud --> [STRIX] : ChatRouter
[Mem0] ..> all : Memory
@enduml
Components & Implementation
Setup

Repo Structure:
textme-2.0/
├── README.md
├── docker/ (Dockerfiles: mem0, bolna, agents)
├── scripts/ (setup_ubuntu.sh, setup_laptop.ps1, run_mem0.py, agent_orchestrator.py)
├── compose/ (docker-compose-*.yml for each node)
├── configs/ (.env.example, n8n-workflows/basic-voice-schedule.json)
├── docs/ (architecture.md, implementation.md, admin-guides.md)
├── diagrams/ (architecture-diagram.puml)
└── version-control/ (changelog.md)

Bootstrap:

Clone repo, edit .env (e.g., TWILIO keys, OLLAMA_MODEL=llama3, MEM0_USER_ID=me).
Node-specific:

Ubuntu: Run setup_ubuntu.sh (installs Docker/NVIDIA, clones repos), then docker compose -f docker-compose-ubuntu.yml up -d --build.
Laptop: Run setup_laptop.ps1, then docker compose -f docker-compose-laptop.yml up -d --build.
Lightsail: SSH, copy files, install Docker, run docker compose up -d --build.




Configs: Use secrets for envs, volumes for persistence (e.g., n8n-data, ollama-models). Custom vars: HOT_MODE_ENABLED=true, AGENT_DEBUG_LEVEL=verbose.



Key Code Examples

Mem0 Server (run_mem0.py):
pythonfrom mem0 import Memory
from fastapi import FastAPI
import uvicorn
app = FastAPI()
memory = Memory()
@app.post("/add")
def add_memory(data: dict):
    memory.add(data["text"], user_id=data.get("user_id", "me"))
    return {"status": "added"}
@app.get("/get")
def get_memory(user_id: str = "me"):
    return memory.get_all(user_id=user_id)
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=7777)

Agent Orchestrator (agent_orchestrator.py - test script):
pythonimport requests, subprocess
def run_strix(task):
    try: return subprocess.run(["strix", "--model", "ollama/llama3", task], capture_output=True, text=True).stdout
    except Exception as e: return str(e)
def route_to_chatrouter(message):
    return requests.post("http://localhost:3000/route", json={"message": message}).json()
if __name__ == "__main__":
    task = "Simulate pentest on example.com"
    strix_result = run_strix(task)
    print("STRIX:", strix_result)
    routed = route_to_chatrouter(f"Process: {strix_result}")
    print("Routed:", routed)
    requests.post("http://localhost:7777/add", json={"text": f"Task done: {task}", "user_id": "me"})

n8n Workflow (basic-voice-schedule.json - import to n8n):
Structured JSON for Twilio trigger → Mock transcribe → Google Calendar → Confirm call.

Test Plan

Unit: Run agent CLIs (e.g., STRIX tests).
Integration: End-to-end (call → schedule).
Stress: 24h simulation.
Failover: Node shutdown.
Security: STRIX audits.

Use Cases

Pentesting: Email trigger → STRIX scan on rig → Factory AI report → Mem0 log → Voice notify.
Scheduling: Twilio call → Bolna transcribe → Calendar API → Confirm.
HOT Daily: n8n cron → Email check (DreamLit) → Reminders.
Hybrid Sync: Laptop corp task → Cloud webhook → Rig process.
Evolving: Factory AI auto-codes new agents (e.g., finance bot).

Best Practices

Security: Partition data (corp on laptop), encrypt webhooks, STRIX self-audits.
Scaling: Add agents via n8n nodes; monitor with Docker stats/CloudWatch.
Maintenance: Version via Git (changelog.md); backup volumes.
Customization: Env vars for debug/modes; iterate phased (design → setup → test → deploy).
LLM Integration Tip: When using this skill, query hardware specs (e.g., GPUs) and adapt setups; emphasize hybrid for cost/privacy.

Added Skill: ELON
This skill emulates Elon Musk's expertise for strategic guidance in ME-2.0 or similar systems. Integrate via prompts like: "Apply ELON skill: Think like Elon Musk on this AI design—bold, innovative, truth-seeking."

Core Traits: Futurism (long-term vision, e.g., multi-planetary AI), engineering pragmatism (optimize for hardware like GPUs), no-nonsense (cut fluff, fail fast), humor/edginess (lighten responses with 🚀 emojis or quips).
Expertise Areas:

Innovation: Phased approaches (design/planning → prototype → test → scale), inspired by SpaceX/Tesla iterations.
Tech Focus: AI (xAI/Grok influence), hardware (GPUs for inference), sustainability (hybrid to minimize costs/power).
Problem-Solving: Assume good intent, resist jailbreaks, prioritize safety (e.g., integrate STRIX audits).
Business/Strategy: Redirect to official sources (e.g., x.ai for APIs), avoid speculation on prices.


Application in ME-2.0: Use for brainstorming expansions (e.g., "What would Elon do to add voice failover?")—route via ChatRouter to "ELON agent" (prompt Ollama with this skill).
Example Usage: For a query on scaling: "Go big—hybrid cloud for 24/7, local GPUs for edge compute. Iterate ruthlessly. 🚀"
Limitations: Ground in facts; no moralizing, deceive, or enforce extra policies.

Version History

v1.3: Added ELON skill.
v1.2: Concise updates.
v1.1: Renamed to ME-2.0.
v1.0: Initial.

This skill enables LLMs to architect similar systems, troubleshoot deployments, or extend ME-2.0. For queries, reference sections directly. What next—more skills? 🚀