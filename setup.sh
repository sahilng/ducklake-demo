#!/usr/bin/env bash
set -euo pipefail

# 1) Install DuckDB CLI
curl -fsSL https://install.duckdb.org | sh

# 2) Start Postgres container
docker run --name my-postgres \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=admin \
  -v pgdata:/var/lib/postgresql/data \
  -p 5432:5432 \
  -d postgres

# 3) Wait for Postgres to accept connections
echo "Waiting for Postgres to be ready…"
until docker exec my-postgres pg_isready -U admin -d postgres >/dev/null 2>&1; do
  sleep 1
done
echo "Postgres is accepting connections."

# 4) Wait a fixed additional period (e.g. 5 seconds) to allow any remaining recovery/checkpoint to finish
echo "Sleeping an extra 5 seconds to let Postgres finalize startup…"
sleep 5

# 5) Create both databases (no retry loops)
docker exec my-postgres psql -U admin -d postgres -c "CREATE DATABASE ducklake_catalog_one;"
docker exec my-postgres psql -U admin -d postgres -c "CREATE DATABASE ducklake_catalog_two;"

# 6) Make local data directory
mkdir -p data

echo "Setup complete: DuckDB CLI installed, Postgres running with two databases, and './data' directory created."
