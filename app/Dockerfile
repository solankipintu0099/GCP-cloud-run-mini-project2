FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY main.py .

RUN useradd --uid 10001 --no-create-home appuser
USER appuser

EXPOSE 8080
# Cloud Run injects PORT; exec keeps gunicorn as PID 1 so it receives SIGTERM.
CMD exec gunicorn --bind ":${PORT}" --workers 2 main:app
