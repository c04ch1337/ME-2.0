#### docker/Dockerfile.agents
FROM python:3.12-slim
WORKDIR /app
### Install core deps
RUN pip install --no-cache-dir strix-ai factory-ai chatrouter requests
### Clone repos if needed (but prefer volume mounts for dev)
###For prod, add: RUN git clone https://github.com/usestrix/strix && cd strix && pip install .
### Expose if API-ified
EXPOSE 5000
CMD ["python", "-m", "http.server", "5000"]  # Placeholder; override with custom script