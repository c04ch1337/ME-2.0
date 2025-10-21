# ME-2.0 Admin Guides (v1.2)

## Maintenance
- Start/Stop: `docker compose up/down`.
- Update: Pull, restart.
- Monitor: `docker logs/ps`.
- Backup: Export n8n/Mem0.

## Use Cases
1. Scheduling: Call → Transcribe → Calendar → Confirm.
2. Pentest: Email → STRIX → Report.
3. HOT Daily: Cron emails/reminders.
4. Voice: Inbound handle/forward.

Troubleshoot: Logs, restarts. Scale: Add RAM.
[Concise v1.2: Summarized guides.]
## GPU selection and environment variables

- Base environment defaults are set in [docker/Dockerfile.base.py310.cu121](docker/Dockerfile.base.py310.cu121) (CUDA_HOME, PATH, LD_LIBRARY_PATH, PYTHONPATH).
- Runtime GPU selection is controlled with CUDA_VISIBLE_DEVICES via [configs/.env](configs/.env). By default, we select GPUs 2 and 3 (the two RTX 3060s) and leave Pascal 1060 cards idle.
- The Ubuntu GPU stack [compose/docker-compose-ubuntu.yml](compose/docker-compose-ubuntu.yml) uses modern Compose GPU settings (gpus: all) and reads CUDA_VISIBLE_DEVICES from the env file. Change the .env value and restart the stack to switch GPUs.