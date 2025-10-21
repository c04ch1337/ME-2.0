# ME-2.0 Implementation (v1.2)

## Steps
1. Bootstrap: Run setup scripts, edit .env.
2. Agents: Clone/install via scripts.
3. Workflows: Import JSON to n8n (e.g., basic-voice-schedule).
4. Sync: Webhooks between nodes.
5. Voice: Twilio webhook to n8n.

## Test Plan
- Unit: Agent CLIs.
- Integration: End-to-end flows.
- Stress: 24h sim.
- Failover: Node shutdowns.
- Security: STRIX audit.
[Concise v1.2: Shortened steps/tests.]