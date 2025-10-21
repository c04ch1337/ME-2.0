#### docker/Dockerfile.agents
FROM python:3.12.6-slim
WORKDIR /app
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_ROOT_USER_ACTION=ignore

# Install git for cloning agent frameworks from source
RUN apt-get update && apt-get install -y --no-install-recommends git && rm -rf /var/lib/apt/lists/*

# Install core dependencies
RUN pip install --no-cache-dir requests

# Vendor all agent frameworks (none are pip-installable packages)
# Clone each to /opt/vendor and install their requirements if present
RUN mkdir -p /opt/vendor && cd /opt/vendor && \
    git clone https://github.com/usestrix/strix && \
    (test -f strix/requirements.txt && pip install --no-cache-dir -r strix/requirements.txt || true) && \
    git clone https://github.com/chatrouter/chatrouter && \
    (test -f chatrouter/requirements.txt && pip install --no-cache-dir -r chatrouter/requirements.txt || true) && \
    git clone https://github.com/Factory-AI/factory && \
    (test -f factory/requirements.txt && pip install --no-cache-dir -r factory/requirements.txt || true)

# Ensure Python can import all vendored frameworks
ENV PYTHONPATH=/opt/vendor/strix:/opt/vendor/chatrouter:/opt/vendor/factory

# Create non-root user
RUN useradd -m -u 10001 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 5000
# Placeholder; override with custom script
CMD ["python", "-m", "http.server", "5000"]