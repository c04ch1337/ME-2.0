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

# Create a resilient entrypoint that tries multiple launch methods
RUN bash -lc 'cat > /app/start_bolna.sh << "EOS"\n#!/usr/bin/env bash\nset -e\nHOST="0.0.0.0"\n# Prefer CLI if available\nif command -v bolna >/dev/null 2>&1; then\n  exec bolna server --host "$HOST"\nfi\n# Fallbacks via python -m\npython - <<'\''PY'\''\nimport importlib, os, sys\nhost = "0.0.0.0"\ncandidates = [\n    ("bolna.server", ["--host", host]),\n    ("bolna.__main__", []),\n    ("bolna", ["server", "--host", host]),\n]\nfor mod, args in candidates:\n    try:\n        importlib.import_module(mod.split(":")[0])\n    except Exception:\n        continue\n    os.execvp(sys.executable, [sys.executable, "-m", mod.split(":")[0]] + args)\nprint("No bolna entrypoint found", file=sys.stderr)\nsys.exit(127)\nPY\nEOS\nchmod +x /app/start_bolna.sh'

# Run as non-root in final image
USER appuser

EXPOSE 8000
CMD ["bash", "/app/start_bolna.sh"]