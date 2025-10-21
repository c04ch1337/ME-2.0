#### docker/Dockerfile.agents
FROM python:3.12.6-slim
WORKDIR /app

# Install git for cloning agent frameworks from source
RUN apt-get update && apt-get install -y --no-install-recommends git && rm -rf /var/lib/apt/lists/*

# Install core dependencies
RUN pip install --no-cache-dir requests

# Install agent frameworks from source (production approach)
# Clone to /tmp, install, then clean up to minimize image size
RUN cd /tmp && \
    git clone https://github.com/usestrix/strix && \
    cd strix && pip install --no-cache-dir . && \
    cd /tmp && \
    git clone https://github.com/Factory-AI/factory && \
    cd factory && pip install --no-cache-dir . && \
    cd /tmp && \
    git clone https://github.com/chatrouter/chatrouter && \
    cd chatrouter && pip install --no-cache-dir . && \
    cd / && rm -rf /tmp/strix /tmp/factory /tmp/chatrouter

# Create non-root user
RUN useradd -m -u 10001 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 5000
# Placeholder; override with custom script
CMD ["python", "-m", "http.server", "5000"]