# OpenCode AI Dockerfile for Podman
FROM docker.io/library/debian:bookworm-slim

# Sicherheits- und Build-Argumente
ARG USER=opencode
ARG UID=1000
ARG GID=1000
ARG OPENCODE_VERSION=latest

# System-Updates und Entwickler-Tools installieren
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # Basis-Tools
    ca-certificates \
    curl \
    wget \
    bash \
    git \
    # Nützliche CLI-Tools
    jq \
    unzip \
    zip \
    vim \
    nano \
    # OpenCode-spezifische Tools
    ripgrep \
    fd-find \
    # Python & Pip
    python3 \
    python3-pip \
    python3-venv \
    # Java Development Kit (OpenJDK 17)
    openjdk-17-jdk \
    # Java Build-Tools
    maven \
    gradle \
    # Weitere nützliche Tools
    build-essential \
    make \
    procps \
    # Netzwerk-Tools
    iputils-ping \
    net-tools \
    dnsutils \
    netcat-openbsd \
    # SSH Client & Server
    openssh-client \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# Symlinks für fd-find erstellen (fd ist unter anderem Namen installiert)
RUN ln -s /usr/bin/fdfind /usr/local/bin/fd

# OpenJDK 21 aus Adoptium/Eclipse Temurin installieren
RUN ARCH=$(dpkg --print-architecture) && \
    wget -O- https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/trusted.gpg.d/adoptium.asc && \
    echo "deb https://packages.adoptium.net/artifactory/deb bookworm main" | tee /etc/apt/sources.list.d/adoptium.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends temurin-21-jdk && \
    rm -rf /var/lib/apt/lists/*

# Node.js LTS (20.x) installieren
RUN ARCH=$(dpkg --print-architecture) && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Bun installieren (schnelle JavaScript Runtime & Package Manager)
RUN curl -fsSL https://bun.sh/install | bash && \
    ln -s /root/.bun/bin/bun /usr/local/bin/bun

# Python als 'python' verfügbar machen
RUN ln -sf /usr/bin/python3 /usr/local/bin/python

# Nicht-root User erstellen für Sicherheit
RUN groupadd -g ${GID} ${USER} && \
    useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER}

# Als neuer User wechseln
USER ${USER}
WORKDIR /home/${USER}

# jenv installieren für Java-Versionsverwaltung
RUN git clone https://github.com/jenv/jenv.git ~/.jenv && \
    echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(jenv init -)"' >> ~/.bashrc && \
    echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.profile && \
    echo 'eval "$(jenv init -)"' >> ~/.profile

# jenv konfigurieren und Java-Versionen hinzufügen
RUN bash -c 'export PATH="$HOME/.jenv/bin:$PATH" && eval "$(jenv init -)" && \
    jenv add /usr/lib/jvm/java-17-openjdk-* && \
    jenv add /usr/lib/jvm/temurin-21-jdk-* && \
    jenv global 21 && \
    jenv enable-plugin export' && \
    echo 'export PATH="$HOME/.jenv/shims:$HOME/.jenv/bin:$PATH"' >> /home/${USER}/.jenv_init && \
    echo 'export JENV_SHELL=bash' >> /home/${USER}/.jenv_init && \
    echo 'export JENV_LOADED=1' >> /home/${USER}/.jenv_init

# Alle wichtigen Tools im PATH verfügbar machen
ENV PATH="/home/${USER}/.jenv/shims:/home/${USER}/.jenv/bin:${PATH}"
ENV JENV_ROOT="/home/${USER}/.jenv"
ENV JENV_SHELL=bash

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

# Sicherstellen dass OpenCode und alle Tools im PATH sind
ENV PATH="/home/${USER}/.opencode/bin:${PATH}"

# Workspace-Verzeichnis erstellen
RUN mkdir -p /home/${USER}/workspace

WORKDIR /home/${USER}/workspace

# Schneller Entrypoint ohne jenv init (wird über ENV geladen)
RUN echo '#!/bin/bash' > /home/${USER}/entrypoint.sh && \
    echo 'exec "$@"' >> /home/${USER}/entrypoint.sh && \
    chmod +x /home/${USER}/entrypoint.sh

# OpenCode direkt starten
ENTRYPOINT ["/home/opencode/entrypoint.sh", "opencode"]
