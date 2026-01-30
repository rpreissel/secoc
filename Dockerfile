# OpenCode AI Dockerfile for Podman
FROM docker.io/library/debian:bookworm-slim

# Sicherheits- und Build-Argumente
ARG USER=opencode
ARG UID=1000
ARG GID=1000
ARG OPENCODE_VERSION=latest

# System-Updates und notwendige Pakete installieren
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    bash \
    git \
    && rm -rf /var/lib/apt/lists/*

# Nicht-root User erstellen für Sicherheit
RUN groupadd -g ${GID} ${USER} && \
    useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER}

# Als neuer User wechseln
USER ${USER}
WORKDIR /home/${USER}

# OpenCode direkt installieren
RUN mkdir -p /home/${USER}/.opencode/bin && \
    ARCH=$(uname -m) && \
    if [ "${ARCH}" = "aarch64" ]; then \
        BINARY_ARCH="arm64"; \
    else \
        BINARY_ARCH="x64"; \
    fi && \
    if [ "${OPENCODE_VERSION}" = "latest" ]; then \
        DOWNLOAD_URL="https://github.com/anomalyco/opencode/releases/latest/download/opencode-linux-${BINARY_ARCH}.tar.gz"; \
    else \
        DOWNLOAD_URL="https://github.com/anomalyco/opencode/releases/download/v${OPENCODE_VERSION}/opencode-linux-${BINARY_ARCH}.tar.gz"; \
    fi && \
    curl -fsSL "${DOWNLOAD_URL}" -o /tmp/opencode.tar.gz && \
    tar -xzf /tmp/opencode.tar.gz -C /home/${USER}/.opencode/bin && \
    rm /tmp/opencode.tar.gz && \
    chmod +x /home/${USER}/.opencode/bin/opencode

# Sicherstellen dass OpenCode im PATH ist
ENV PATH="/home/${USER}/.opencode/bin:${PATH}"

# Workspace-Verzeichnis erstellen
RUN mkdir -p /home/${USER}/workspace

WORKDIR /home/${USER}/workspace

# OpenCode beim Start automatisch ausführen
ENTRYPOINT ["opencode"]
