#### docker/Dockerfile.mem0
FROM python:3.12-slim
WORKDIR /app
RUN pip install --no-cache-dir mem0ai uvicorn
COPY ./run_mem0.py .
EXPOSE 7777
CMD ["uvicorn", "run_mem0:app", "--host", "0.0.0.0", "--port", "7777"]