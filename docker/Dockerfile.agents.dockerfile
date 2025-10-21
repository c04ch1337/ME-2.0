#### docker/Dockerfile.agents
FROM python:3.12.6-slim
WORKDIR /app
### Install core deps
# Strix/Factory are not on PyPI; install only runtime deps here to avoid build failures.
# For Strix/Factory usage, clone and install from source in a separate stage or via volume mounts.
RUN pip install --no-cache-dir requests
### Clone repos if needed (but prefer volume mounts for dev)
###For prod, add: RUN git clone https://github.com/usestrix/strix && cd strix && pip install .
### Expose if API-ified
RUN useradd -m -u 10001 appuser && chown -R appuser:appuser /app
USER appuser
EXPOSE 5000
# Placeholder; override with custom script
CMD ["python", "-m", "http.server", "5000"]