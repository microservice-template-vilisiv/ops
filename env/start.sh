#!/bin/bash

set -e

# Path to the project directory (where docker-compose.yml is located)
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/module/postgres" && pwd)"

# Trap Ctrl+C (SIGINT) to shut everything down cleanly
cleanup() {
  echo -e "\n🛑 Interrupt received, stopping services..."

  # Stop all running services using docker-compose in the correct directory
  echo "🧹 Stopping services..."
  docker-compose -f "$PROJECT_DIR/docker-compose.yml" down

  echo "✅ All services stopped. Exiting."
  exit 0
}

trap cleanup SIGINT

echo "🚀 Starting all environment scripts..."

# Path to the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/script" && pwd)"

# Loop through and run each script in the directory
for script in "$SCRIPT_DIR"/*.sh; do
  if [[ -x "$script" ]]; then
    echo "▶️ Running $script"
    bash "$script" &
  fi
done

# Wait for all background jobs to finish
wait

# After starting all services, follow their logs in the terminal
echo "📜 Displaying logs from all services..."

# Display logs from all running services managed by docker-compose
docker-compose -f "$PROJECT_DIR/docker-compose.yml" logs -f

