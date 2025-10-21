#### docker/Dockerfile.bolna
FROM python:3.12-slim
WORKDIR /app
RUN pip install --no-cache-dir bolna twilio
#Add custom configs/scripts if needed For now, basic - run via entrypoint script
EXPOSE 8000  # Bolna default
CMD ["bolna", "server", "--host", "0.0.0.0"]