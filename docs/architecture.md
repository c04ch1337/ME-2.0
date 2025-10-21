# ME-2.0 Architecture (v1.2)

## Tech Stack
- Orchestration: n8n (hybrid self-host).
- Comms: ChatRouter.
- Memory: Mem0.
- Agents: STRIX (pentest), Factory AI (code), DreamLit (email), Twilio/Bolna (voice).
- Infra: Ubuntu rig (GPUs/Docker/Ollama), Windows laptop (Docker Desktop), Lightsail (cloud).

## Design
Tri-node mesh:
1. Laptop: Corp edge, triggers.
2. Rig: GPU heavy, agents.
3. Cloud: Hub, persistence.

Flow: Input → n8n → ChatRouter → Agents/Mem0 → Output. HOT via crons.

## Why?
Hybrid resilience, scalable, secure, cost-effective, agentic swarm.
[Concise v1.2: Trimmed for scannability.]