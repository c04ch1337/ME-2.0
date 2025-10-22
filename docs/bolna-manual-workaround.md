# Bolna Manual Workaround (Run From Source Inside Container)

This guide shows how to run Bolna manually from its GitHub source inside the running container. Use this when the packaged entrypoint is unavailable (for example, “No module named bolna.server”).

Linked files:
- Compose (Ubuntu GPU): [compose/docker-compose-ubuntu.yml](compose/docker-compose-ubuntu.yml)
- Bolna Dockerfile: [docker/Dockerfile.bolna.dockerfile](docker/Dockerfile.bolna.dockerfile)
- Example env file: [configs/.env.example.txt](configs/.env.example.txt)

When to use this
- You see logs like:
  - `/usr/bin/python: No module named bolna.server`
  - Or CLI “bolna” not found
- You want Bolna running now while we standardize the upstream entrypoint.

What you’ll do
- Rebuild and enter the Bolna container
- Clone the Bolna repo inside the container
- Install Bolna in editable mode
- Launch the real ASGI app with uvicorn
- Optional: persist source across restarts with a bind mount

Prerequisites
- Docker and NVIDIA Container Toolkit are installed if using GPU.
- Your .env is created from the example:
  - Copy example to real env:
    - `cp configs/.env.example.txt configs/.env`
  - If Bolna or mem0 use OpenAI, set your key in [configs/.env](configs/.env):
    - `OPENAI_API_KEY=...`
  - To avoid OpenAI for mem0, you can set (optional):
    - `MEM0_EMBEDDINGS_PROVIDER=fastembed`

Step 1 — Rebuild Bolna clean and start the container
Run from the project root:
```bash
# Rebuild Bolna with a clean cache
docker compose -f compose/docker-compose-ubuntu.yml build --no-cache bolna

# Start (or restart) bolna
docker compose -f compose/docker-compose-ubuntu.yml up -d bolna

# Enter a root shell inside bolna
docker compose -f compose/docker-compose-ubuntu.yml exec -u 0 bolna bash
```

Step 2 — Clone Bolna into /opt/bolna and install editable
In the container shell:
```bash
git clone https://github.com/bolna-ai/bolna /opt/bolna
python -m pip install --no-cache-dir -e /opt/bolna

# Quick introspection to see what’s available
python - <<'PY'
import bolna, pkgutil
print('bolna file:', getattr(bolna, '__file__', None))
mods = [m.name for m in pkgutil.walk_packages(bolna.__path__, bolna.__name__+'.')]
print('bolna submodules (first 30):', mods[:30])
PY
```

Step 3 — Launch the ASGI app with uvicorn (try in this order)
In the container shell, try these commands one by one until one works:
```bash
# Common candidates
uvicorn bolna.server:app --host 0.0.0.0 --port 8000
uvicorn bolna.api:app    --host 0.0.0.0 --port 8000
uvicorn bolna.app:app    --host 0.0.0.0 --port 8000

# If the package has a module main that runs the server
python -m bolna
```

If none of those exist, search for plausible candidates:
```bash
python - <<'PY'
import importlib, pkgutil
b = importlib.import_module('bolna')
cands = []
for m in pkgutil.walk_packages(b.__path__, 'bolna.'):
    if m.name.endswith(('.server', '.api', '.app', '.main')):
        cands.append(m.name)
print('ASGI candidates:', cands)
PY
```
Once you identify a candidate module exposing `app`, run:
```bash
uvicorn <candidate>:app --host 0.0.0.0 --port 8000
```

Optional — Keep it running after you close the shell
```bash
nohup uvicorn bolna.api:app --host 0.0.0.0 --port 8000 >/tmp/bolna.log 2>&1 &
```

Step 4 — Persist the source across container recreates (optional)
To avoid re-cloning each time:
1) On the host, create a vendor folder:
```bash
mkdir -p vendor/bolna
git clone https://github.com/bolna-ai/bolna vendor/bolna
```
2) Add a volume to the bolna service in [compose/docker-compose-ubuntu.yml](compose/docker-compose-ubuntu.yml):
```yaml
  bolna:
    build:
      context: ..
      dockerfile: docker/Dockerfile.bolna.dockerfile
    ports:
      - "8000:8000"
    env_file:
      - ../configs/.env
    volumes:
      - ../vendor/bolna:/opt/bolna
    # (rest unchanged)
```
3) Inside the running container:
```bash
python -m pip install --no-cache-dir -e /opt/bolna
uvicorn bolna.api:app --host 0.0.0.0 --port 8000
```

GPU selection reminder (Ubuntu stack)
- We explicitly pin GPUs 2 and 3 (RTX 3060s) in [compose/docker-compose-ubuntu.yml](compose/docker-compose-ubuntu.yml) using `device_ids: ['2', '3']` for GPU services like ollama/bolna.
- If you need different GPUs, edit the device IDs and recreate.

Mem0 note (OpenAI dependency)
- If mem0 errors with “OPENAI_API_KEY required,” set `OPENAI_API_KEY` in [configs/.env](configs/.env).
- Or switch to local embeddings by setting:
  - `MEM0_EMBEDDINGS_PROVIDER=fastembed`

Going back to automated startup later
Once the correct import path for the ASGI app is confirmed (for example, `bolna.api:app`), we will:
- Update the run command in [docker/Dockerfile.bolna.dockerfile](docker/Dockerfile.bolna.dockerfile) to start uvicorn with that module.
- Optionally pin the repo commit that exposes that app.
- Update compose so it starts automatically without manual steps.

Troubleshooting
- “command not found: uvicorn” — Install uvicorn inside the container: `python -m pip install uvicorn`
- “address already in use” — Some process is already on port 8000. Change to `--port 8001` or stop the other process.
- “ModuleNotFoundError for bolna.*” — Ensure `/opt/bolna` exists and was installed editable (`pip install -e /opt/bolna`). If running as non-root user, verify permissions on `/opt/bolna`.

Copy/paste summary
```bash
# Rebuild and enter
docker compose -f compose/docker-compose-ubuntu.yml build --no-cache bolna
docker compose -f compose/docker-compose-ubuntu.yml up -d bolna
docker compose -f compose/docker-compose-ubuntu.yml exec -u 0 bolna bash

# Clone + install
git clone https://github.com/bolna-ai/bolna /opt/bolna
python -m pip install --no-cache-dir -e /opt/bolna
python -c "import bolna, pkgutil; print(getattr(bolna,'__file__',None)); print([m.name for m in pkgutil.walk_packages(bolna.__path__, bolna.__name__+'.')][:30])"

# Try to run
uvicorn bolna.server:app --host 0.0.0.0 --port 8000 || \
uvicorn bolna.api:app    --host 0.0.0.0 --port 8000 || \
uvicorn bolna.app:app    --host 0.0.0.0 --port 8000 || \
python -m bolna