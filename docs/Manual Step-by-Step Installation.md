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

---

## Complete Bolna Telephony Platform (Production Setup)

The basic Bolna setup above runs a single service for voice AI. For production telephony capabilities with real phone calls (Twilio or Plivo), you need a complete 5-service stack.

### What's the Difference?

**Basic Setup (above):** Single [`bolna`](docker/Dockerfile.bolna.dockerfile) container for voice AI testing.

**Complete Telephony Platform (this section):** Full production stack with:
- Phone call handling (Twilio/Plivo)
- Webhook tunneling (ngrok)
- Session management (Redis)
- Voice AI processing (Bolna)

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    External Services                         │
│  Twilio/Plivo (Phone Network) ──► ngrok Public URL          │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
         ┌───────────────────────────────┐
         │   ngrok (Webhook Tunnel)      │  Port 4040 (dashboard)
         │   Exposes webhooks publicly   │
         └──────────┬────────────────────┘
                    │
        ┌───────────┴───────────┐
        ▼                       ▼
┌──────────────┐        ┌──────────────┐
│ twilio-app   │        │ plivo-app    │  Ports 8001, 8002
│ (Port 8001)  │        │ (Port 8002)  │  (Telephony handlers)
└──────┬───────┘        └───────┬──────┘
       │                        │
       └────────┬───────────────┘
                ▼
        ┌──────────────┐
        │  bolna-app   │  Port 5001 (Main voice AI)
        │  (Port 5001) │
        └──────┬───────┘
               │
               ▼
        ┌──────────────┐
        │    Redis     │  Port 6379 (State/sessions)
        │  (Port 6379) │
        └──────────────┘
```

### The 5 Services Explained

| Service | Purpose | Port | Dependencies |
|---------|---------|------|--------------|
| **bolna-app** | Main voice AI application, handles conversations | 5001 | Redis |
| **redis** | Stores session state, call data, conversation history | 6379 | None |
| **ngrok** | Creates public HTTPS tunnel for webhooks from Twilio/Plivo | 4040 (dashboard) | None |
| **twilio-app** | Handles Twilio telephony events and call routing | 8001 | Redis, ngrok, bolna-app |
| **plivo-app** | Handles Plivo telephony events (alternative to Twilio) | 8002 | Redis, ngrok, bolna-app |

### Prerequisites

Before setting up the complete platform, you need:

1. **Ngrok account and auth token:**
   - Sign up at https://ngrok.com
   - Get your auth token from the dashboard
   - Create [`configs/ngrok-config.yml`](configs/ngrok-config.yml) with your token (see below)

2. **Telephony provider account:**
   - **Option A: Twilio** - Get account SID and auth token from https://twilio.com
   - **Option B: Plivo** - Get auth ID and auth token from https://plivo.com
   - Add credentials to your [`.env`](configs/.env) file

3. **Updated environment file:**
   - Your [`.env`](configs/.env) needs additional variables (see Configuration section below)

### Configuration Files Required

#### 1. Create ngrok-config.yml

Create this file in your project root directory (same level as docker-compose file):

```yaml
version: "2"
authtoken: YOUR_NGROK_AUTH_TOKEN
tunnels:
  twilio:
    proto: http
    addr: twilio-app:8001
  plivo:
    proto: http
    addr: plivo-app:8002
  bolna:
    proto: http
    addr: bolna-app:5001
```

**Replace `YOUR_NGROK_AUTH_TOKEN`** with your actual ngrok token.

#### 2. Update .env File

Add these variables to your [`configs/.env`](configs/.env):

```bash
# Ngrok
NGROK_AUTHTOKEN=your_ngrok_auth_token

# Twilio (if using Twilio)
TWILIO_ACCOUNT_SID=your_twilio_account_sid
TWILIO_AUTH_TOKEN=your_twilio_auth_token
TWILIO_PHONE_NUMBER=your_twilio_phone_number

# Plivo (if using Plivo)
PLIVO_AUTH_ID=your_plivo_auth_id
PLIVO_AUTH_TOKEN=your_plivo_auth_token
PLIVO_PHONE_NUMBER=your_plivo_phone_number

# Redis
REDIS_HOST=redis
REDIS_PORT=6379

# Bolna
BOLNA_HOST=bolna-app
BOLNA_PORT=5001
```

### Docker Compose Configuration

Create a new file [`compose/docker-compose-bolna-telephony.yml`](compose/docker-compose-bolna-telephony.yml) with this complete setup:

```yaml
version: '3.8'

services:
  bolna-app:
    build:
      context: .
      dockerfile: docker/Dockerfile.bolna.dockerfile
    image: bolna-app:latest
    container_name: bolna-app
    ports:
      - "5001:5001"
    depends_on:
      - redis
    env_file:
      - configs/.env
    volumes:
      - ./agent_data:/app/agent_data
      - $HOME/.aws/credentials:/root/.aws/credentials:ro
      - $HOME/.aws/config:/root/.aws/config:ro
    restart: unless-stopped

  redis:
    image: redis:latest
    container_name: bolna-redis
    ports:
      - "6379:6379"
    restart: unless-stopped
    volumes:
      - redis-data:/data

  ngrok:
    image: ngrok/ngrok:latest
    container_name: bolna-ngrok
    restart: unless-stopped
    command:
      - "start"
      - "--all"
      - "--config"
      - "/etc/ngrok.yml"
    volumes:
      - ./ngrok-config.yml:/etc/ngrok.yml
    ports:
      - "4040:4040"
    depends_on:
      - bolna-app
      - twilio-app
      - plivo-app

  twilio-app:
    build:
      context: .
      dockerfile: docker/Dockerfile.twilio.dockerfile
    image: twilio-app:latest
    container_name: twilio-app
    ports:
      - "8001:8001"
    depends_on:
      - redis
      - bolna-app
    env_file:
      - configs/.env
    restart: unless-stopped

  plivo-app:
    build:
      context: .
      dockerfile: docker/Dockerfile.plivo.dockerfile
    image: plivo-app:latest
    container_name: plivo-app
    ports:
      - "8002:8002"
    depends_on:
      - redis
      - bolna-app
    env_file:
      - configs/.env
    restart: unless-stopped

volumes:
  redis-data:
```

### Step-by-Step Deployment

#### Step 1: Prepare Configuration Files

```bash
# Create ngrok config (edit with your auth token)
touch ngrok-config.yml

# Update environment file
cp configs/.env.example.txt configs/.env
# Edit configs/.env with your API keys
```

#### Step 2: Start the Complete Stack

```bash
# Start all 5 services
docker compose -f compose/docker-compose-bolna-telephony.yml up --build

# Or run in background (detached mode)
docker compose -f compose/docker-compose-bolna-telephony.yml up -d --build
```

#### Step 3: Verify Each Service

Check that all services are running:

```bash
# View all running containers
docker ps

# You should see 5 containers:
# - bolna-app (port 5001)
# - bolna-redis (port 6379)
# - bolna-ngrok (port 4040)
# - twilio-app (port 8001)
# - plivo-app (port 8002)
```

#### Step 4: Get Ngrok Public URLs

Open the ngrok dashboard to get your webhook URLs:

```
http://localhost:4040
```

You'll see 3 public URLs:
- **Twilio tunnel:** `https://xxxxx.ngrok.io` → points to `twilio-app:8001`
- **Plivo tunnel:** `https://yyyyy.ngrok.io` → points to `plivo-app:8002`
- **Bolna tunnel:** `https://zzzzz.ngrok.io` → points to `bolna-app:5001`

#### Step 5: Configure Webhooks in Twilio/Plivo

**For Twilio:**
1. Log into https://console.twilio.com
2. Go to Phone Numbers → Active Numbers
3. Select your phone number
4. Under "Voice & Fax", set:
   - **Webhook URL:** `https://xxxxx.ngrok.io/webhooks/twilio` (your Twilio ngrok URL)
   - **HTTP Method:** POST
5. Save

**For Plivo:**
1. Log into https://console.plivo.com
2. Go to Phone Numbers → Your Numbers
3. Select your phone number
4. Under "Application", set:
   - **Answer URL:** `https://yyyyy.ngrok.io/webhooks/plivo` (your Plivo ngrok URL)
   - **HTTP Method:** POST
5. Save

### Testing the Setup

#### Test 1: Check Service Health

```bash
# Check bolna-app
curl http://localhost:5001/health

# Check Redis
docker exec bolna-redis redis-cli ping
# Should return: PONG

# Check twilio-app
curl http://localhost:8001/health

# Check plivo-app
curl http://localhost:8002/health
```

#### Test 2: Verify Ngrok Tunnels

```bash
# Check ngrok status API
curl http://localhost:4040/api/tunnels

# Or open in browser
# http://localhost:4040/inspect/http
```

#### Test 3: Make a Test Call

1. Call your Twilio or Plivo phone number
2. The call should be routed through ngrok → telephony app → bolna-app
3. Check logs to verify the flow:

```bash
# View logs for all services
docker compose -f compose/docker-compose-bolna-telephony.yml logs -f

# Or view individual service logs
docker logs bolna-app -f
docker logs twilio-app -f
docker logs bolna-ngrok -f
```

### Port Reference Table

| Service | Internal Port | External Port | Purpose |
|---------|--------------|---------------|---------|
| bolna-app | 5001 | 5001 | Voice AI API |
| redis | 6379 | 6379 | Session storage |
| ngrok | 4040 | 4040 | Tunnel dashboard |
| twilio-app | 8001 | 8001 | Twilio webhooks |
| plivo-app | 8002 | 8002 | Plivo webhooks |

### Troubleshooting

#### Redis Connection Errors

**Symptom:** Services can't connect to Redis

```bash
# Check if Redis is running
docker exec bolna-redis redis-cli ping

# Check Redis logs
docker logs bolna-redis

# Verify network connectivity
docker exec bolna-app ping redis
```

**Solution:** Ensure all services are on the same Docker network and Redis started first.

#### Ngrok Tunnel Failures

**Symptom:** Ngrok won't start or shows authentication errors

```bash
# Check ngrok logs
docker logs bolna-ngrok

# Common issues:
# 1. Invalid auth token in ngrok-config.yml
# 2. Ngrok config file not mounted correctly
# 3. Services not reachable from ngrok container
```

**Solutions:**
1. Verify your auth token: https://dashboard.ngrok.com/get-started/your-authtoken
2. Check file mount: `docker exec bolna-ngrok cat /etc/ngrok.yml`
3. Ensure service dependencies started before ngrok

#### Telephony Webhook Problems

**Symptom:** Phone calls don't connect or webhook errors in logs

```bash
# Check telephony app logs
docker logs twilio-app -f
docker logs plivo-app -f

# Check ngrok request inspector
# Open: http://localhost:4040/inspect/http
```

**Common issues:**
1. **Wrong webhook URL:** Ensure you used the correct ngrok URL in Twilio/Plivo dashboard
2. **Webhook path incorrect:** URLs should end with `/webhooks/twilio` or `/webhooks/plivo`
3. **SSL/TLS errors:** Ngrok provides HTTPS by default, ensure your provider accepts it
4. **Port conflicts:** Make sure ports 8001 and 8002 aren't used by other services

**Solutions:**
- Verify webhook URL in provider dashboard matches ngrok URL
- Test webhook with curl: `curl https://xxxxx.ngrok.io/webhooks/twilio`
- Check ngrok dashboard for detailed request/response logs

#### Service Dependencies Not Ready

**Symptom:** Services fail to start or crash immediately

```bash
# Check start order
docker compose -f compose/docker-compose-bolna-telephony.yml ps

# Services should start in this order:
# 1. redis
# 2. bolna-app
# 3. twilio-app, plivo-app
# 4. ngrok
```

**Solution:** Use `depends_on` in compose file (already configured above) or add health checks.

#### AWS Credentials Not Found

**Symptom:** bolna-app crashes with AWS credential errors

```bash
# Check if AWS credentials are mounted
docker exec bolna-app ls -la ~/.aws/
```

**Solutions:**
1. Ensure you have AWS credentials: `~/.aws/credentials` and `~/.aws/config`
2. If you don't use AWS, remove volume mounts from compose file:
   ```yaml
   # Remove these lines from bolna-app volumes:
   # - $HOME/.aws/credentials:/root/.aws/credentials:ro
   # - $HOME/.aws/config:/root/.aws/config:ro
   ```

### Monitoring and Logs

#### View All Service Logs

```bash
# Follow all logs
docker compose -f compose/docker-compose-bolna-telephony.yml logs -f

# View specific service
docker compose -f compose/docker-compose-bolna-telephony.yml logs -f bolna-app

# View last 100 lines
docker compose -f compose/docker-compose-bolna-telephony.yml logs --tail=100
```

#### Check Resource Usage

```bash
# Monitor container resources
docker stats

# Check specific container
docker stats bolna-app
```

#### Access Redis CLI

```bash
# Connect to Redis
docker exec -it bolna-redis redis-cli

# Inside Redis CLI, check keys
redis> KEYS *
redis> GET <key_name>
redis> EXIT
```

### Stopping and Restarting

```bash
# Stop all services
docker compose -f compose/docker-compose-bolna-telephony.yml down

# Stop and remove volumes (WARNING: deletes Redis data)
docker compose -f compose/docker-compose-bolna-telephony.yml down -v

# Restart all services
docker compose -f compose/docker-compose-bolna-telephony.yml restart

# Restart single service
docker compose -f compose/docker-compose-bolna-telephony.yml restart bolna-app
```

### Data Persistence

Redis data is stored in a named volume (`redis-data`). This persists across container restarts.

To backup Redis data:

```bash
# Create backup
docker exec bolna-redis redis-cli SAVE
docker cp bolna-redis:/data/dump.rdb ./redis-backup.rdb

# Restore backup
docker cp ./redis-backup.rdb bolna-redis:/data/dump.rdb
docker restart bolna-redis
```

### Production Considerations

For production deployments:

1. **Use persistent ngrok domain:** Upgrade ngrok to paid plan for static URLs
2. **Add health checks:** Configure Docker health checks for all services
3. **Set up monitoring:** Use Prometheus/Grafana for metrics
4. **Configure logging:** Use centralized logging (ELK, CloudWatch)
5. **Enable Redis persistence:** Configure Redis RDB or AOF
6. **Implement rate limiting:** Add rate limits to webhook endpoints
7. **Use secrets management:** Store credentials in Docker secrets or vault
8. **Add SSL certificates:** If not using ngrok, configure SSL for webhooks

### Additional Resources

- **Bolna Manual Workaround Guide:** [`docs/bolna-manual-workaround.md`](docs/bolna-manual-workaround.md)
- **Architecture Documentation:** [`docs/architecture.md`](docs/architecture.md)
- **Environment Configuration:** [`configs/.env.example.txt`](configs/.env.example.txt)
- **Ngrok Documentation:** https://ngrok.com/docs
- **Twilio Webhooks:** https://www.twilio.com/docs/usage/webhooks
- **Plivo Webhooks:** https://www.plivo.com/docs/voice/concepts/webhooks/

### Quick Command Reference

```bash
# Start complete stack
docker compose -f compose/docker-compose-bolna-telephony.yml up -d --build

# Check service status
docker ps
docker compose -f compose/docker-compose-bolna-telephony.yml ps

# View logs
docker compose -f compose/docker-compose-bolna-telephony.yml logs -f

# Access ngrok dashboard
open http://localhost:4040

# Check Redis
docker exec bolna-redis redis-cli ping

# Stop everything
docker compose -f compose/docker-compose-bolna-telephony.yml down

# Clean restart (removes volumes)
docker compose -f compose/docker-compose-bolna-telephony.yml down -v
docker compose -f compose/docker-compose-bolna-telephony.yml up -d --build
```