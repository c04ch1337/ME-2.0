#### docker/Dockerfile.mem0
FROM python:3.12.6-slim
WORKDIR /app
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_ROOT_USER_ACTION=ignore
RUN pip install --no-cache-dir mem0ai uvicorn fastapi
COPY ./run_mem0.py .
RUN useradd -m -u 10001 appuser && chown -R appuser:appuser /app
USER appuser
EXPOSE 7777
CMD ["uvicorn", "run_mem0:app", "--host", "0.0.0.0", "--port", "7777"]