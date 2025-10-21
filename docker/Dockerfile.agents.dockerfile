#### docker/Dockerfile.agents
FROM python:3.12.6-slim
WORKDIR /app
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_ROOT_USER_ACTION=ignore

# Install git for cloning agent frameworks from source
RUN apt-get update && apt-get install -y --no-install-recommends git && rm -rf /var/lib/apt/lists/*

# Install core dependencies
RUN pip install --no-cache-dir requests

# Install agent frameworks from source (production approach)
# Clone to /tmp, install, then clean up to minimize image size
# Install agent frameworks: use pip VCS for packaged repos; vendor non-packaged repos
RUN pip install --no-cache-dir \
    git+https://github.com/usestrix/strix@main \
    git+https://github.com/chatrouter/chatrouter@main

# Try installing Factory-AI/factory as a package; if not, vendor it and install its requirements
RUN set -eux; \
    pip install --no-cache-dir git+https://github.com/Factory-AI/factory@main || true; \
    mkdir -p /opt/vendor && cd /opt/vendor; \
    if [ ! -d factory ]; then \
      git clone https://github.com/Factory-AI/factory; \
      if [ -f factory/requirements.txt ]; then pip install --no-cache-dir -r factory/requirements.txt; fi; \
    fi

# Ensure Python can import vendored factory if needed
ENV PYTHONPATH=/opt/vendor/factory:${PYTHONPATH}

# Create non-root user
RUN useradd -m -u 10001 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 5000
# Placeholder; override with custom script
CMD ["python", "-m", "http.server", "5000"]