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

# Verify bolna installation and make CLI accessible
RUN python -m pip show bolna || echo "Bolna package installed but not in pip list"

# Run as non-root in final image
USER appuser

# Bolna default - use python -m instead of CLI to avoid PATH issues
EXPOSE 8000
CMD ["python", "-m", "bolna.server", "--host", "0.0.0.0"]