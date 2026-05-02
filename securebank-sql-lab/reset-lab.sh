#!/usr/bin/env bash

# SecureBank SQL Lab reset helper.
# This removes the PostgreSQL Docker volume, recreates the lab, and prints
# the Adminer connection details for workshop participants.

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$PROJECT_DIR"

echo "SecureBank SQL Lab reset is starting..."
echo "Stopping containers and removing database volume..."
docker compose down -v

echo "Starting fresh containers..."
docker compose up -d

cat <<'INFO'

SecureBank SQL Lab is ready.

Adminer URL:
  http://localhost:8080
  http://HOST_IP:8080

Adminer login:
  System: PostgreSQL
  Server: db
  Username: admin
  Password: securebank123
  Database: securebank

DB01 student login:
  System: PostgreSQL
  Server: db
  Username: db01_user
  Password: db01pass123
  Database: db01_sql_basics

DB02 student login:
  System: PostgreSQL
  Server: db
  Username: db02_user
  Password: db02pass123
  Database: db02_relations_joins

DB03 student login:
  System: PostgreSQL
  Server: db
  Username: db03_user
  Password: db03pass123
  Database: db03_banking_queries

DB04 student login:
  System: PostgreSQL
  Server: db
  Username: db04_user
  Password: db04pass123
  Database: db04_access_control_lab

DB05 student login:
  System: PostgreSQL
  Server: db
  Username: db05_user
  Password: db05pass123
  Database: db05_sql_injection_lab

DB06 student login:
  System: PostgreSQL
  Server: db
  Username: db06_user
  Password: db06pass123
  Database: db06_audit_forensics_lab

DB07 student login:
  System: PostgreSQL
  Server: db
  Username: db07_user
  Password: db07pass123
  Database: db07_ai_sql_risk_lab

DB08 Red Team login:
  System: PostgreSQL
  Server: db
  Username: db08_red_user
  Password: db08redpass123
  Database: db08_red_vs_blue_final

DB08 Blue Team login:
  System: PostgreSQL
  Server: db
  Username: db08_blue_user
  Password: db08bluepass123
  Database: db08_red_vs_blue_final

Useful checks:
  docker ps
  docker compose logs

INFO
