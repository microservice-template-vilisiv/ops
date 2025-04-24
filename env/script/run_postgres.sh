#!/bin/bash
set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
COMPOSE_DIR="$PROJECT_ROOT/module/postgres"

# Log files
LOG_DIR="$PROJECT_ROOT/logs"
POSTGRES_LOG="$LOG_DIR/postgres.log"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Initial echo to terminal
echo "🚀 Starting Postgres containers..."

cd "$COMPOSE_DIR"

# Start containers (in detached mode) and write output to log
docker-compose up -d >> "$POSTGRES_LOG" 2>&1

echo "✅ Postgres containers started."
echo "📄 Logs are being written to $POSTGRES_LOG"

# Wait for Postgres containers to become healthy
echo "⏳ Waiting for Postgres containers to become healthy..."

MAX_WAIT=60
WAITED=0

# Get the container IDs of the Postgres containers
CONTAINER_IDS=$(docker ps -q --filter "name=keycloak" --filter "name=appdb")

if [[ -z "$CONTAINER_IDS" ]]; then
  echo "❌ No Postgres containers found!"
  exit 1
fi

# Wait for containers to become healthy
while true; do
  HEALTH_STATUS=$(docker inspect --format '{{.Name}} {{.State.Health.Status}}' $CONTAINER_IDS 2>/dev/null)

  if [[ $? -ne 0 || -z "$HEALTH_STATUS" ]]; then
    echo "❌ Failed to get health status, retrying..."
  else
    UNHEALTHY=$(echo "$HEALTH_STATUS" | grep -v healthy || true)

    if [[ -z "$UNHEALTHY" ]]; then
      echo "✅ Postgres containers are healthy!"
      break
    fi
  fi

  if [[ $WAITED -ge $MAX_WAIT ]]; then
    echo "❌ Timeout waiting for Postgres containers to be healthy"
    echo "$HEALTH_STATUS"
    exit 1
  fi

  sleep 2
  WAITED=$((WAITED + 2))
done

# Short delay to allow log output to accumulate
echo "⏳ Waiting a few seconds to ensure logs are being produced..."
sleep 5

# Stream logs to file
echo "📜 Tailing logs from Postgres containers..."
# docker-compose logs -f >> "$POSTGRES_LOG" 2>&1
# docker-compose logs -f 2>&1 | tee -a "$POSTGRES_LOG"
script -q -c "docker-compose logs -f" /dev/null | tee -a "$POSTGRES_LOG"
