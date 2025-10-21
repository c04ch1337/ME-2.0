#### docker/Dockerfile.bolna
FROM python:3.12.6-slim
WORKDIR /app
# Install git for pip VCS installs
RUN apt-get update && apt-get install -y --no-install-recommends git && rm -rf /var/lib/apt/lists/*
# Install bolna directly from GitHub (PyPI may not host it; repo uses master branch).
# Pin to a specific commit/tag when you standardize releases.
RUN pip install --no-cache-dir "git+https://github.com/bolna-ai/bolna" twilio
#Add custom configs/scripts if needed For now, basic - run via entrypoint script
RUN useradd -m -u 10001 appuser && chown -R appuser:appuser /app
USER appuser
# Bolna default
EXPOSE 8000
CMD ["bolna", "server", "--host", "0.0.0.0"]