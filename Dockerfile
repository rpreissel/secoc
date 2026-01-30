# OpenCode AI Dockerfile for Podman
FROM docker.io/library/debian:bookworm-slim

# Sicherheits- und Build-Argumente
ARG USER=opencode
ARG UID=1000
ARG GID=1000

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

# OpenCode installieren
RUN curl -fsSL https://opencode.ai/install | bash

# Sicherstellen dass OpenCode im PATH ist
ENV PATH="/home/${USER}/.opencode/bin:${PATH}"

# Workspace-Verzeichnis erstellen
RUN mkdir -p /home/${USER}/workspace

WORKDIR /home/${USER}/workspace

# OpenCode beim Start automatisch ausführen
CMD ["opencode"]
