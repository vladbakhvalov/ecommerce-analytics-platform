FROM python:3.12-slim

WORKDIR /usr/app/dbt

RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc libpq-dev git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
    dbt-core==1.9.0 \
    dbt-postgres==1.9.0

COPY . .

ENTRYPOINT ["dbt"]