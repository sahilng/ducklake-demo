#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# 1) Install DuckDB CLI (if not already on PATH)
# -----------------------------------------------------------------------------
if ! command -v duckdb >/dev/null 2>&1; then
  curl -fsSL https://install.duckdb.org | sh
fi

# -----------------------------------------------------------------------------
# 2) Start Postgres container (only if it doesn't already exist)
# -----------------------------------------------------------------------------
if [ "$(docker ps -a --format='{{.Names}}' | grep -x my-postgres || true)" != "my-postgres" ]; then
  docker run --name my-postgres \
    -e POSTGRES_USER=admin \
    -e POSTGRES_PASSWORD=admin \
    -v pgdata:/var/lib/postgresql/data \
    -p 5432:5432 \
    -d postgres
else
  # If container exists but is stopped, start it
  if [ "$(docker inspect -f '{{.State.Running}}' my-postgres)" != "true" ]; then
    docker start my-postgres
  fi
fi

# -----------------------------------------------------------------------------
# 3) Wait until Postgres accepts connections
# -----------------------------------------------------------------------------
echo "Waiting for Postgres to be ready on 'my-postgres' container..."
until docker exec my-postgres pg_isready -U admin -d postgres >/dev/null 2>&1; do
  sleep 1
done
echo "Postgres is accepting connections."

# -----------------------------------------------------------------------------
# 4) Create first database (ducklake_catalog_one) with automatic retry
# -----------------------------------------------------------------------------
echo "Creating database 'ducklake_catalog_one' (retries until it succeeds)..."
until docker exec my-postgres \
       psql -U admin -d postgres -c "CREATE DATABASE ducklake_catalog_one;" >/dev/null 2>&1; do
  # If Postgres is momentarily busy (checkpointing, starting up, etc.), retry
  sleep 1
done
echo "✓ Created ducklake_catalog_one"

# -----------------------------------------------------------------------------
# 5) Create second database (ducklake_catalog_two) with automatic retry
# -----------------------------------------------------------------------------
echo "Creating database 'ducklake_catalog_two' (retries until it succeeds)..."
until docker exec my-postgres \
       psql -U admin -d postgres -c "CREATE DATABASE ducklake_catalog_two;" >/dev/null 2>&1; do
  sleep 1
done
echo "✓ Created ducklake_catalog_two"

# -----------------------------------------------------------------------------
# 6) Make your data directory
# -----------------------------------------------------------------------------
mkdir -p data
echo "Data directory is ready at ./data"

