#### docker/Dockerfile.bolna
FROM me2-base:py310-cu121

# Ensure working directory (also set in base)
WORKDIR /app

# Copy curated non-torch dependencies (torch stack provided by base image)
COPY docker/requirements/bolna-py310-cu121.txt /tmp/requirements/bolna-py310-cu121.txt

# Install dependencies first, then bolna without deps (pinned) and twilio
USER root
RUN pip install -r /tmp/requirements/bolna-py310-cu121.txt
RUN pip install --no-deps "git+https://github.com/bolna-ai/bolna@83cfee34c54200fd59a5c6f2bd6d330d0fdafc49" twilio

# Run as non-root in final image
USER appuser

# Bolna default
EXPOSE 8000
CMD ["bolna", "server", "--host", "0.0.0.0"]