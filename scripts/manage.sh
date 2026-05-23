#!/bin/bash
#
# Unified script for managing the ROS development Docker container lifecycle.
#
# Usage: ROS_DISTRO=jazzy ./scripts/manage.sh [start|stop|restart|recreate|logs|exec]
#

set -euo pipefail

# --- Configuration (parameterized by ROS_DISTRO; defaults to 'jazzy') ---
ROS_DISTRO="${ROS_DISTRO:-jazzy}"
export ROS_DISTRO
SERVICE_NAME="ros-dev"

# --- Helper Functions ---
function print_usage() {
    echo "Usage: ROS_DISTRO=<humble|jazzy|...> $0 [start|stop|restart|recreate|logs|exec]"
    echo "  start     - Build and start the container in detached mode."
    echo "  stop      - Stop the running container."
    echo "  restart   - Restart the container."
    echo "  recreate  - Stop, remove, and rebuild the container from scratch."
    echo "  logs      - Follow the container's log output."
    echo "  exec      - Attach a bash shell to the running container."
}

# --- Main Logic ---
ACTION=${1:-"help"}

case "$ACTION" in
    start)
    echo "Starting ROS development container for ROS_DISTRO='${ROS_DISTRO}'..."
    echo "Granting GUI access (X11)..."
    xhost +local:docker 2>/dev/null || true
    docker compose up -d --build
    echo "Service '${SERVICE_NAME}' started. Use './scripts/manage.sh exec' to open a shell."
        ;;
    stop)
        echo "Stopping container..."
        docker compose stop
        echo "Stopped."
        ;;
    restart)
        echo "Restarting container..."
        docker compose restart
        echo "Restarted."
        ;;
    recreate)
    echo "Recreating container (code and data on host are preserved: ./workspace, ./data)..."
    echo "Granting GUI access (X11)..."
    xhost +local:docker 2>/dev/null || true
    docker compose down
    docker compose up -d --build
    echo "Recreated."
        ;;
    logs)
        echo "Following container logs (Ctrl+C to exit)..."
        docker compose logs -f
        ;;
    exec)
        echo "Attaching bash to Compose service '${SERVICE_NAME}'..."
        docker compose exec "${SERVICE_NAME}" bash
        ;;
    *)
        print_usage
        exit 1
        ;;
esac
