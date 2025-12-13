# Extends your pre-built image (tag is provided by docker-compose.yml via BASE_IMAGE)

ARG BASE_IMAGE=adyansh04/ros-dev:jazzy
FROM ${BASE_IMAGE}

# Add editor tooling (clangd, ruff)
RUN apt-get update && apt-get install -y clangd-14 && \
    update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-14 100 && \
    pip install --no-cache-dir ruff && \
    rm -rf /var/lib/apt/lists/*

# Ensure default workspace exists (mounted from host: ./workspace -> /root/workspace)
RUN mkdir -p /root/workspace/src
RUN mkdir -p /root/data/

# Copy vscode folder into the workspace
COPY .vscode /root/workspace/src/.vscode

# Default working directory inside the container
WORKDIR /root/workspace