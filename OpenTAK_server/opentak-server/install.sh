#!/bin/bash
set -euo pipefail

echo " ---------- Install script ----------"
echo "Welcome to the OpenTAK server installation script!"
echo "This script will guide you through the installation process."
echo "Make sure Docker + Docker Compose are installed."
echo ""

echo " ---------- Configuration ----------"

read -p "Enter the port for the REST API on the host (default: 8080): " HOST_API_PORT
HOST_API_PORT=${HOST_API_PORT:-8080}

read -p "Enter the MariaDB port on the host (default: 3307): " HOST_DB_PORT
HOST_DB_PORT=${HOST_DB_PORT:-3307}

read -p "Enter the database name (default: opentak): " DATABASE_NAME
DATABASE_NAME=${DATABASE_NAME:-opentak}

read -p "Enter the database user (default: default): " DATABASE_USER
DATABASE_USER=${DATABASE_USER:-default}

read -sp "Enter the database password (can be empty): " DATABASE_PASSWORD
echo ""

read -p "Enter the username for the master admin user (default: admin): " MASTER_USER
MASTER_USER=${MASTER_USER:-admin}

read -sp "Enter the password for the master admin user: " MASTER_PASSWORD
echo ""

read -p "Enter MQTT broker URL (default: mqtt://mqtt.kaktusgame.eu:1883): " MQTT_BROKER_HOST
MQTT_BROKER_HOST=${MQTT_BROKER_HOST:-mqtt://mqtt.kaktusgame.eu:1883}

# IMPORTANT: inside Docker network, DB host is the service name:
DATABASE_HOST=mysql-db
DATABASE_PORT=3306

# Build DATABASE_URL for Prisma/app
# (Password may contain special chars; for full robustness you should URL-encode it.
#  We'll do a safe encode via python3 if available.)
ENCODED_PASSWORD="$DATABASE_PASSWORD"
if command -v python3 >/dev/null 2>&1; then
  ENCODED_PASSWORD="$(python3 - <<'PY'
import os, urllib.parse
print(urllib.parse.quote(os.environ["PW"], safe=""))
PY
PW="$DATABASE_PASSWORD")"
fi

DATABASE_URL="mysql://${DATABASE_USER}:${ENCODED_PASSWORD}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME}"

echo ""
echo " ---------- Writing env files ----------"

mkdir -p ./Docker
mkdir -p ./REST

SECRET=$(openssl rand -hex 32)
sed -i '' "s/\$\$REPLACE_WITH_SECRET\$\$/${SECRET}/g" ./RMQTT/jwt.toml

# Compose env (used by Docker/docker-compose.yml)
cat > ./Docker/.env <<EOF
# Ports on the host machine
HOST_API_PORT=${HOST_API_PORT}
HOST_DB_PORT=${HOST_DB_PORT}

# Database config (container-to-container)
DATABASE_NAME=${DATABASE_NAME}
DATABASE_USER=${DATABASE_USER}
DATABASE_PASSWORD=${DATABASE_PASSWORD}
DATABASE_HOST=${DATABASE_HOST}
DATABASE_PORT=${DATABASE_PORT}
DATABASE_URL=${DATABASE_URL}

# Master admin bootstrap
MASTER_USER=${MASTER_USER}
MASTER_PASSWORD=${MASTER_PASSWORD}

# MQTT
MQTT_BROKER_HOST=${MQTT_BROKER_HOST}
EOF

# Optional: also write REST/.env for running backend outside Docker
cat > ./REST/.env <<EOF
DATABASE_NAME=${DATABASE_NAME}
DATABASE_USER=${DATABASE_USER}
DATABASE_PASSWORD=${DATABASE_PASSWORD}
DATABASE_HOST=localhost
DATABASE_PORT=${HOST_DB_PORT}
DATABASE_URL=mysql://${DATABASE_USER}:${ENCODED_PASSWORD}@localhost:${HOST_DB_PORT}/${DATABASE_NAME}

MASTER_USER=${MASTER_USER}
MASTER_PASSWORD=${MASTER_PASSWORD}

MQTT_BROKER_HOST=${MQTT_BROKER_HOST}
SECRET_CODE=${SECRET}
EOF

echo "Wrote:"
echo " - ./Docker/.env"
echo " - ./REST/.env"
echo ""

echo " ---------- Starting containers ----------"
cd Docker
docker compose up -d --build

echo ""
echo " ---------- Installation complete ----------"
echo "Backend should be reachable at: http://localhost:${HOST_API_PORT}"
