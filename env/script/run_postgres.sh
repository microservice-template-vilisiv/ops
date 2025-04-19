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

# Initial echo to terminal (will appear even in background)
echo "🚀 Starting Postgres containers in the background..."

cd "$COMPOSE_DIR"  # Now it will correctly go to module/postgres

# Run docker-compose up in background, but still show initial output to terminal
docker-compose up -d >> "$POSTGRES_LOG" 2>&1 &

# Capture background process ID
POSTGRES_PID=$!

# Echo to terminal after running the background process
echo "✅ Postgres containers are now running in the background."
echo "📄 Logs are being written to $POSTGRES_LOG"
echo "📝 Background process ID: $POSTGRES_PID"

# Optionally, save the process ID for later use
echo "$POSTGRES_PID" > "$LOG_DIR/postgres.pid"

