#!/bin/bash
#
# Unified script for managing the ROS development Docker container lifecycle.
#
# Usage: ROS_DISTRO=jazzy ./scripts/manage.sh [start|stop|restart|recreate|logs|exec]
#

set -e

# --- Configuration (parameterized by ROS_DISTRO; defaults to 'jazzy') ---
ROS_DISTRO="${ROS_DISTRO:-jazzy}"
export ROS_DISTRO
CONTAINER_NAME="ros_dev_${ROS_DISTRO}"

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

# Ensures .vscode exists inside host workspace so files are visible inside the container.
function ensure_vscode_in_workspace() {
    local repo_root
    repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    local src_vscode="${repo_root}/.vscode"

    if [ ! -d "${src_vscode}" ]; then
        echo "No .vscode folder in repo root (${src_vscode}); skipping copy."
        return 0
    fi

    local dest="${repo_root}/workspace/src/.vscode"
    if [ -d "${dest}" ]; then
        echo ".vscode already present at ${dest}; skipping."
    else
        echo "Copying .vscode configuration to workspace..."
        mkdir -p "${repo_root}/workspace/src"
        cp -r "${src_vscode}" "${dest}"
    fi
}

# --- Main Logic ---
ACTION=${1:-"help"}

case "$ACTION" in
    start)
    echo "Starting ROS development container for ROS_DISTRO='${ROS_DISTRO}'..."
    echo "Preparing workspace and copying default .vscode if missing..."
    ensure_vscode_in_workspace
    echo "Granting GUI access (X11)..."
    xhost +local:docker 2>/dev/null || true
    docker compose up -d --build
    echo "Container '${CONTAINER_NAME}' started. Use './scripts/manage.sh exec' to open a shell."
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
    echo "Preparing workspace and copying default .vscode if missing..."
    ensure_vscode_in_workspace
    docker compose down
    docker compose up -d --build
    echo "Recreated."
        ;;
    logs)
        echo "Following container logs (Ctrl+C to exit)..."
        docker compose logs -f
        ;;
    exec)
        echo "Attaching bash to '${CONTAINER_NAME}'..."
        docker exec -it "${CONTAINER_NAME}" bash
        ;;
    *)
        print_usage
        exit 1
        ;;
esac