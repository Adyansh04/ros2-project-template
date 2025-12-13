# ROS 2 Project Development Template

This repository provides a lightweight, reproducible containerized ROS 2 development environment tuned for VS Code, clangd, and common robotics workflows. It follows a **Docker Compose-first** workflow, making it easy to run on any system.

## Features

- **Compose-first workflow**: Start the container with `docker compose up -d`, then attach VS Code or use `docker exec`.
- **Pre-configured tooling**: Clangd for C++ IntelliSense and Ruff for Python linting/formatting.
- **GPU support**: NVIDIA Container Toolkit integration for GPU-accelerated workloads.
- **Parameterized ROS distro**: Easily switch between Humble, Jazzy, or other ROS 2 distributions.
- **Customizable Dockerfile**: Add project-specific dependencies easily.

## Prerequisites

- Docker Engine & Docker Compose
- (Optional, for GPU) NVIDIA Container Toolkit
- (Optional) Visual Studio Code with Dev Containers extension

## Quick Start

### 1. Clone the Repository

```bash
git clone <your-template-repo-url>
cd ros2_project_template

# If the repo contains submodules, initialize them:
git submodule update --init --recursive
```

### 2. Start the Container (Compose-first)

```bash
docker compose up -d
```

This starts the development container in detached mode using the default ROS distro (Jazzy).

### 3. Attach to the Container

**Option A: VS Code (Recommended for development)**

1. Open the repository folder in VS Code.
2. Click **"Reopen in Container"** when prompted (or use Command Palette: `Dev Containers: Reopen in Container`).
3. VS Code will attach to the running `ros-dev` service with all extensions pre-configured.

> **Note**: The `.devcontainer/` configuration is optional. It enhances VS Code integration by auto-installing extensions and settings, but the container works independently of VS Code via `docker compose`.

**Option B: Terminal**

```bash
docker exec -it ros_dev_jazzy bash
```

Or use the management script:

```bash
./scripts/manage.sh exec
```

## Directory Structure

```
ros2-project-template/
├── workspace/           # ROS 2 workspace (bind-mounted into container)
│   └── src/             # Place your packages and git submodules here
├── data/                # Shared data folder for host-container file sharing
├── scripts/             # Helper scripts (manage.sh)
├── .devcontainer/       # VS Code Dev Container configuration (optional)
│   └── Dockerfile       # Customize this for project-specific dependencies
├── .vscode/             # VS Code settings (clangd, ruff, tasks)
├── .clang-format        # C++ formatting rules
├── .clangd              # Clangd configuration
├── ruff.toml            # Python linting/formatting rules
├── .env.example         # Environment variable template
├── .gitmodules.example  # Git submodules example
└── docker-compose.yml   # Docker Compose orchestration
```

### Host ↔ Container Mount Mapping

| Host Path       | Container Path     | Description                     |
|-----------------|--------------------|---------------------------------|
| `./workspace`   | `/root/workspace`  | ROS 2 workspace (bind mount)    |
| `./data`        | `/root/data`       | Shared data folder              |
| `/tmp/.X11-unix`| `/tmp/.X11-unix`   | X11 socket for GUI apps         |
| `/dev`          | `/dev`             | Hardware device access          |
| `~/.ssh`        | `/root/.ssh`       | SSH keys (read-only)            |

## Customizing the Dockerfile

The `.devcontainer/Dockerfile` is designed for easy customization. Add your project-specific dependencies in the marked section:

```dockerfile
# ============================================================================
# PROJECT-SPECIFIC CUSTOMIZATION
# Add your project dependencies below. Examples:
# ============================================================================

# Install additional ROS packages (uses ROS_DISTRO from base image):
RUN apt-get update && apt-get install -y \
    ros-jazzy-navigation2 \
    ros-jazzy-slam-toolbox \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages:
RUN pip install --no-cache-dir numpy scipy opencv-python

# Install system dependencies:
RUN apt-get update && apt-get install -y \
    libopencv-dev \
    libeigen3-dev \
    && rm -rf /var/lib/apt/lists/*
```

> **Note**: Replace `jazzy` with your target ROS distro (e.g., `humble`) as needed.

After modifying the Dockerfile, rebuild the image:

```bash
docker compose down
docker compose up -d --build
# Or: ./scripts/manage.sh recreate
```

## Switching ROS Distributions

The default ROS distro is **Jazzy**. To use a different distribution (e.g., Humble):

```bash
# Set environment variable before starting
export ROS_DISTRO=humble
docker compose up -d

# Or inline:
ROS_DISTRO=humble docker compose up -d

# Or copy and edit .env.example:
cp .env.example .env
# Edit .env to set ROS_DISTRO=humble
docker compose up -d
```

The container will be named `ros_dev_<distro>` (e.g., `ros_dev_humble`).

## Adding Git Submodules (Package Management)

To add external ROS packages as git submodules:

```bash
# Add a package repository as a submodule
git submodule add <repository-url> workspace/src/<package_name>

# Example: Add a custom robot description package
git submodule add https://github.com/example/my_robot_description.git workspace/src/my_robot_description

# Initialize and update submodules (for fresh clones)
git submodule update --init --recursive
```

See `.gitmodules.example` for example configurations.

## Building the Workspace

Inside the container:

```bash
# Source ROS and build
source /opt/ros/${ROS_DISTRO}/setup.bash
cd /root/workspace
colcon build --symlink-install --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

# Source the workspace
source install/setup.bash
```

Or use the VS Code build task (`Ctrl+Shift+B`).

## Using the `data/` Folder

The `data/` folder is intended for sharing files between the host and container:
- Place datasets, bag files, or configuration files here.
- Access them inside the container at `/root/data`.

```bash
# Example: Copy a rosbag to the data folder on host
cp ~/Downloads/my_recording.db3 ./data/

# Access inside container
ros2 bag play /root/data/my_recording.db3
```

## Management Script

The `scripts/manage.sh` script provides convenient commands for container lifecycle management:

```bash
# Make the script executable (first time only)
chmod +x scripts/manage.sh

# Start the container
./scripts/manage.sh start

# Stop the container
./scripts/manage.sh stop

# Restart the container
./scripts/manage.sh restart

# Rebuild and restart (after Dockerfile changes)
./scripts/manage.sh recreate

# Follow container logs
./scripts/manage.sh logs

# Attach a bash shell
./scripts/manage.sh exec
```

To use a different ROS distro with the script:

```bash
ROS_DISTRO=humble ./scripts/manage.sh start
```

## Tooling Configuration

### Clangd (C++ IntelliSense)

- Configuration: `.clangd` (project root)
- Format rules: `.clang-format` (project root)
- The build task generates `compile_commands.json` in `workspace/build/` for accurate IntelliSense.

### Ruff (Python Linting/Formatting)

- Configuration: `ruff.toml` (project root)
- VS Code is configured to format Python files with Ruff on save.

### VS Code Extensions

Recommended extensions are defined in `.vscode/extensions.json` and `.devcontainer/devcontainer.json`, and are automatically installed when using the Dev Container.

## About the Dev Container (Optional)

The `.devcontainer/` folder provides VS Code-specific integration:

- **Auto-installs extensions**: Clangd, Ruff, ROS tools, CMake, etc.
- **Pre-configures settings**: Editor settings, formatters, IntelliSense.
- **Runs postCreateCommand**: Builds workspace on first open to generate `compile_commands.json`.

**You don't need the Dev Container if:**
- You're not using VS Code
- You prefer to manage extensions manually
- You're using the container via `docker exec` or another IDE

The container works fully independently via `docker compose up -d`.

## GPU and GUI Notes

- **GPU**: Uses NVIDIA Container Toolkit. Ensure it's installed on the host for GPU access.
- **GUI**: X11 forwarding is configured automatically. Run `xhost +local:docker` on the host if GUI apps don't display.

## Troubleshooting

### Packages not visible inside container
Verify they exist under `workspace/src/` on the host.

### IntelliSense missing headers
1. Ensure `ROS_DISTRO` environment variable is set in the container.
2. Run `colcon build` to generate `compile_commands.json`.

### GPU not detected
Verify NVIDIA Container Toolkit is installed:
```bash
docker run --rm --gpus all nvidia/cuda:12.0-base nvidia-smi
```

### Inspect container mounts
```bash
docker inspect --format '{{json .Mounts}}' ros_dev_jazzy | jq
```

## Rebuilding the Docker Image

After modifying `Dockerfile` or `docker-compose.yml`:

```bash
docker compose down
docker compose up -d --build

# Or using the script:
./scripts/manage.sh recreate
```

---

**Happy coding!** 🤖

