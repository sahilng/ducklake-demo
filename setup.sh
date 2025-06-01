#!/bin/bash
set -e

# 1) Install DuckDB (if not already installed)
curl https://install.duckdb.org | sh

# 2) Run Postgres container
docker run --name my-postgres \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=admin \
  -v pgdata:/var/lib/postgresql/data \
  -p 5432:5432 \
  -d postgres

# 3) Wait until Postgres is accepting connections
echo "Waiting for Postgres to be ready..."
until docker exec my-postgres pg_isready -U admin > /dev/null 2>&1; do
  sleep 1
done

# 4) Create both databases with a single psql invocation
docker exec my-postgres psql -U admin -d postgres -c "
  CREATE DATABASE ducklake_catalog_one;
  CREATE DATABASE ducklake_catalog_two;
"

# 5) Make your data directory
mkdir -p data

