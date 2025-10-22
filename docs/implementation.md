# ME-2.0 Implementation (v1.2)

## Steps
1. Bootstrap: Run setup scripts, edit .env.
2. Agents: Clone/install via scripts.
3. Workflows: Import JSON to n8n (e.g., basic-voice-schedule).
4. Sync: Webhooks between nodes.
5. Voice: Twilio webhook to n8n.

## Bolna Telephony Integration
**5-Service Architecture**: Production voice AI platform via Twilio/Plivo.

### Components
- **bolna-app** (5001): Core voice AI, conversation logic.
- **redis** (6379): Session state, call data persistence.
- **ngrok** (4040): Public webhook tunnel for telephony providers.
- **twilio-app** (8001): Twilio SIP/WebRTC integration.
- **plivo-app** (8002): Alternative telephony provider.

### Call Flow
```
Twilio/Plivo → ngrok → twilio-app/plivo-app → bolna-app → redis
                                              ↓
                                          mem0 + ollama
```

### Integration Points
- **mem0**: Conversation memory storage.
- **ollama/OpenAI**: LLM inference for responses.
- **n8n**: Workflow triggers (call events, transcripts).
- **Environment**: Redis connection vars, telephony credentials.

### Network Topology
- All 5 services must share Docker network.
- External ports: 4040 (ngrok dashboard), 5001 (bolna API), 8001/8002 (telephony).
- Internal: redis (6379), inter-service communication.

### Security
- ngrok tunnels: HTTPS by default, auth token required.
- Credentials: Twilio SID/token, Plivo auth ID/token in [`.env`](../configs/.env).
- Redis: No external exposure, internal network only.

### Scaling
- Horizontal: twilio-app, plivo-app (stateless).
- Vertical: bolna-app (LLM processing), redis (session storage).
- Single redis for session consistency.

### Configuration
- **Required files**: [`ngrok-config.yml`](../configs/ngrok-config.yml), [`.env`](../configs/.env)
- **Compose**: [`docker-compose-bolna-telephony.yml`](../compose/docker-compose-bolna-telephony.yml)
- **Details**: [Manual Step-by-Step Installation.md](Manual Step-by-Step Installation.md#complete-bolna-telephony-platform-production-setup)

### Quick Start
```bash
# Setup
cp configs/.env.example.txt configs/.env
# Edit .env + create ngrok-config.yml with auth token

# Deploy
docker compose -f compose/docker-compose-bolna-telephony.yml up -d --build

# Verify
curl http://localhost:5001/health
docker exec bolna-redis redis-cli ping
open http://localhost:4040  # ngrok dashboard

# Configure webhooks in Twilio/Plivo with ngrok URLs
```

[See detailed setup, troubleshooting in Manual Step-by-Step Installation.md]

## Test Plan
- Unit: Agent CLIs.
- Integration: End-to-end flows.
- Stress: 24h sim.
- Failover: Node shutdowns.
- Security: STRIX audit.
[Concise v1.2: Shortened steps/tests.]