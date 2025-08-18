# Extends your pre-built image (tag is provided by docker-compose.yml via BASE_IMAGE)

ARG BASE_IMAGE=adyansh04/ros-dev:humble-latest
FROM ${BASE_IMAGE}

# Add editor tooling (clangd, ruff)
RUN apt-get update && apt-get install -y clangd-14 && \
    update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-14 100 && \
    pip install --no-cache-dir ruff && \
    rm -rf /var/lib/apt/lists/*

# Ensure default workspace exists (mounted from host: ./workspaces -> /workspaces)
RUN mkdir -p /root/workspaces/ros2_ws/src
RUN mkdir -p /root/workspaces/colcon_ws/src
RUN mkdir -p /root/data/

# Copy vscode folder into the workspace
COPY .vscode /root/workspaces/ros2_ws/src/.vscode
COPY .vscode /root/workspaces/colcon_ws/src/.vscode

# Default working directory inside the container
WORKDIR /root/workspaces/ros2_ws