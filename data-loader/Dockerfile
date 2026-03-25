FROM python:3.12-slim

WORKDIR /app

# System dependencies for psycopg2
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential libpq-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ ./src/

CMD ["python", "-m", "src.main"]