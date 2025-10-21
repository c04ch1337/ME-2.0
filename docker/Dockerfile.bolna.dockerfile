#### docker/Dockerfile.bolna
FROM python:3.12.6-slim
WORKDIR /app
# Install bolna directly from GitHub (PyPI may not host it). Pin to a tag/commit when you standardize releases.
RUN pip install --no-cache-dir "git+https://github.com/bolna-ai/bolna@main" twilio
#Add custom configs/scripts if needed For now, basic - run via entrypoint script
RUN useradd -m -u 10001 appuser && chown -R appuser:appuser /app
USER appuser
# Bolna default
EXPOSE 8000
CMD ["bolna", "server", "--host", "0.0.0.0"]