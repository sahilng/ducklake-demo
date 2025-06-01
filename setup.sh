#!/bin/bash
set -e

# 1) Install DuckDB CLI (if not already on PATH)
curl https://install.duckdb.org | sh

# 2) Start Postgres container
docker run --name my-postgres \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=admin \
  -v pgdata:/var/lib/postgresql/data \
  -p 5432:5432 \
  -d postgres

# 3) Wait until Postgres accepts connections
echo "Waiting for Postgres to be ready..."
until docker exec my-postgres pg_isready -U admin > /dev/null 2>&1; do
  sleep 1
done

# 4) Create first database (ducklake_catalog_one) on its own connection
docker exec my-postgres \
  psql -U admin -d postgres -c "CREATE DATABASE ducklake_catalog_one;"

# 5) Wait again, because creating a database involves a checkpoint
echo "Waiting a moment for Postgres to stabilize..."
until docker exec my-postgres pg_isready -U admin > /dev/null 2>&1; do
  sleep 1
done

# 6) Create second database (ducklake_catalog_two) on its own connection
docker exec my-postgres \
  psql -U admin -d postgres -c "CREATE DATABASE ducklake_catalog_two;"

# 7) Make your data directory
mkdir -p data

