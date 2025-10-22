#### docker/Dockerfile.bolna
FROM me2-base:py310-cu121

# Ensure working directory (also set in base)
WORKDIR /app

# Ensure local source is always importable (even if editable install isn't visible to non-root)
ENV PYTHONPATH=/opt/bolna:$PYTHONPATH

# Copy curated non-torch dependencies (torch stack provided by base image)
COPY docker/requirements/bolna-py310-cu121.txt /tmp/requirements/bolna-py310-cu121.txt

# Install dependencies first, then bolna without deps (pinned) and twilio
USER root
RUN pip install -r /tmp/requirements/bolna-py310-cu121.txt
RUN git clone https://github.com/bolna-ai/bolna /opt/bolna && pip install --no-cache-dir -e /opt/bolna && pip install --no-cache-dir twilio
RUN pip install --no-cache-dir uvicorn

# Verify bolna installation and make CLI accessible
RUN python -m pip show bolna || echo "Bolna package installed but not in pip list"

# Create a resilient entrypoint that tries multiple launch methods with diagnostics
RUN bash -lc 'cat > /app/start_bolna.sh << "EOS"\n#!/usr/bin/env bash\nset -e\nHOST=\"${HOST:-0.0.0.0}\"\nPORT=\"${PORT:-8000}\"\n\necho \"[bolna] Python: $(python --version)\"\necho \"[bolna] Checking installed bolna modules...\"\npython - <<'\"'PY'\"'\nimport pkgutil, sys\nmods = [m.name for m in pkgutil.iter_modules() if m.name.startswith(\"bolna\")]\nprint(\"Discovered:\", mods)\ntry:\n    import bolna\n    print(\"bolna __file__ =\", getattr(bolna, \"__file__\", None))\nexcept Exception as e:\n    print(\"import bolna failed:\", e)\nPY\n\n# Prefer CLI if available\nif command -v bolna >/dev/null 2>&1; then\n  echo \"[bolna] Launching via CLI\"\n  exec bolna server --host \"${HOST}\"\nfi\n\n# Helper to attempt a command and report\ntry_run() {\n  echo \"[bolna] Trying: $*\"\n  \"$@\" && exit 0 || echo \"[bolna] Failed: $*\"\n}\n\n# Try several module/ASGI entrypoints\ntry_run python -m bolna.server --host \"${HOST}\"\ntry_run python -m bolna\ntry_run uvicorn bolna.server:app --host \"${HOST}\" --port \"${PORT}\"\n\necho \"[bolna] No known entrypoint worked; sleeping 3s and exiting 127\"\nsleep 3\nexit 127\nEOS\nchmod +x /app/start_bolna.sh'

# Run as non-root in final image
USER appuser

EXPOSE 8000
CMD ["bash", "/app/start_bolna.sh"]