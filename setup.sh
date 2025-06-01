#!/bin/bash

set -e  # Exit on any error

# Install DuckDB
curl https://install.duckdb.org | sh

# Start Postgres container
docker run --name my-postgres \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=admin \
  -v pgdata:/var/lib/postgresql/data \
  -p 5432:5432 \
  -d postgres

# Wait for Postgres to be ready
echo "Waiting for Postgres to be ready..."
until docker exec my-postgres pg_isready -U admin > /dev/null 2>&1; do
  sleep 1
done

# Create databases
docker exec -i my-postgres psql -U admin -c "CREATE DATABASE ducklake_catalog;"
docker exec -i my-postgres psql -U admin -c "CREATE DATABASE ducklake_catalog_two;"
