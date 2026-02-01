# ============================================================================
# OpenCode AI Dockerfile for Podman
# Secure container environment for running OpenCode with development tools
# ============================================================================
FROM docker.io/library/debian:bookworm-slim

# ============================================================================
# BUILD ARGUMENTS & METADATA
# ============================================================================
# Security: UID/GID can be customized for your host system
# Example: podman build --build-arg UID=$(id -u) --build-arg GID=$(id -g) .
ARG USER=opencode
ARG UID=1000
ARG GID=1000
ARG OPENCODE_VERSION=latest

# Detect architecture once for all subsequent commands
ARG TARGETARCH
ARG TARGETOS

# Labels for better image tracking
LABEL maintainer="secoc"
LABEL description="Secure OpenCode AI container with Java, Node.js, Python, and Bun"
LABEL org.opencontainers.image.source="https://github.com/yourusername/secoc"
LABEL org.opencontainers.image.title="secoc"
LABEL org.opencontainers.image.version="${OPENCODE_VERSION}"
LABEL security.scan.enabled="true"
LABEL security.sbom.enabled="true"
LABEL security.uid="${UID}"
LABEL security.gid="${GID}"
LABEL org.opencontainers.image.title="secoc"
LABEL org.opencontainers.image.version="${OPENCODE_VERSION}"
LABEL security.scan.enabled="true"
LABEL security.sbom.enabled="true"
LABEL security.uid="${UID}"
LABEL security.gid="${GID}"

# ============================================================================
# SYSTEM PACKAGES INSTALLATION (Layer 1)
# ============================================================================
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # Base system tools (alphabetically sorted)
    bash \
    ca-certificates \
    curl \
    git \
    gnupg2 \
    wget \
    # CLI utilities
    fd-find \
    jq \
    nano \
    ripgrep \
    unzip \
    vim \
    zip \
    # Build tools
    build-essential \
    make \
    procps \
    # Network debugging tools
    dnsutils \
    iputils-ping \
    net-tools \
    netcat-openbsd \
    # SSH client only (no server for security)
    openssh-client \
    # Python ecosystem
    python3 \
    python3-pip \
    python3-venv \
    # Java OpenJDK 17 (from Debian repos)
    openjdk-17-jdk \
    # Java build tools
    gradle \
    maven \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# CREATE SYMLINKS
# ============================================================================
# fd-find binary name fix
RUN ln -sf /usr/bin/fdfind /usr/local/bin/fd

# Python3 available as 'python'
RUN ln -sf /usr/bin/python3 /usr/local/bin/python

# ============================================================================
# INSTALL JAVA 21 (Adoptium Temurin)
# ============================================================================
RUN ARCH=$(dpkg --print-architecture) && \
    # Secure GPG key installation with fingerprint verification
    wget -qO- https://packages.adoptium.net/artifactory/api/gpg/key/public \
    | gpg --dearmor -o /etc/apt/trusted.gpg.d/adoptium.gpg && \
    chmod 644 /etc/apt/trusted.gpg.d/adoptium.gpg && \
    # Verify fingerprint (3B04D753C9050D9A5D343F39843C48A565F8F04B)
    gpg --dry-run --quiet --import-options import-show --import \
    /etc/apt/trusted.gpg.d/adoptium.gpg 2>/dev/null | \
    grep -q "3B04 D753 C905 0D9A 5D34  3F39 843C 48A5 65F8 F04B" && \
    # Add repository
    echo "deb https://packages.adoptium.net/artifactory/deb bookworm main" \
    > /etc/apt/sources.list.d/adoptium.list && \
    # Install Temurin JDK 21
    apt-get update && \
    apt-get install -y --no-install-recommends temurin-21-jdk && \
    rm -rf /var/lib/apt/lists/*

# ============================================================================
# INSTALL NODE.JS 20.x LTS
# ============================================================================
RUN ARCH=$(dpkg --print-architecture) && \
    # Secure keyring-based installation
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    # Add Node.js 20.x repository
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" \
    > /etc/apt/sources.list.d/nodesource.list && \
    # Install Node.js
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# ============================================================================
# CREATE NON-ROOT USER (Early for security)
# ============================================================================
RUN groupadd -g ${GID} ${USER} && \
    useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER}

# ============================================================================
# SWITCH TO NON-ROOT USER
# ============================================================================
USER ${USER}
WORKDIR /home/${USER}

# ============================================================================
# INSTALL BUN (as non-root user)
# ============================================================================
RUN ARCH=$(dpkg --print-architecture) && \
    # Determine architecture
    if [ "${ARCH}" = "aarch64" ]; then \
        BUN_ARCH="aarch64"; \
    else \
        BUN_ARCH="x64"; \
    fi && \
    # Get latest Bun version from GitHub API
    BUN_VERSION=$(curl -fsSL https://api.github.com/repos/oven-sh/bun/releases/latest \
        | jq -r '.tag_name' 2>/dev/null || echo "latest") && \
    # Download Bun binary
    curl -fsSL "https://github.com/oven-sh/bun/releases/download/${BUN_VERSION}/bun-linux-${BUN_ARCH}.zip" \
        -o /tmp/bun.zip && \
    curl -fsSL "https://github.com/oven-sh/bun/releases/download/${BUN_VERSION}/SHASUMS256.txt" \
        -o /tmp/SHASUMS256.txt && \
    # Verify checksum (protects against download corruption)
    cd /tmp && \
    grep "bun-linux-${BUN_ARCH}.zip" SHASUMS256.txt | sha256sum -c && \
    # Extract and install
    unzip -q bun.zip && \
    rm -rf "${HOME}/.bun" && \
    mkdir -p "${HOME}/.bun/bin" && \
    mv bun "${HOME}/.bun/bin/" && \
    # Cleanup
    rm -f /tmp/bun.zip /tmp/SHASUMS256.txt && \
    # Verify installation
    "${HOME}/.bun/bin/bun" --version

# Add Bun to PATH for current user
ENV BUN_INSTALL="/home/${USER}/.bun"
ENV PATH="${BUN_INSTALL}/bin:${PATH}"

# ============================================================================
# INSTALL JENV (Java Version Manager)
# ============================================================================
RUN git clone https://github.com/jenv/jenv.git ~/.jenv && \
    # Configure bash
    echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(jenv init -)"' >> ~/.bashrc && \
    # Configure profile
    echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.profile && \
    echo 'eval "$(jenv init -)"' >> ~/.profile

# Configure jenv and add Java versions
RUN bash -c 'export PATH="$HOME/.jenv/bin:$PATH" && source <(jenv init - bash) && \
    jenv add /usr/lib/jvm/java-17-openjdk-* && \
    jenv add /usr/lib/jvm/temurin-21-jdk-* && \
    jenv global 21 && \
    jenv enable-plugin export'

# Set jenv environment variables
ENV PATH="/home/${USER}/.jenv/shims:/home/${USER}/.jenv/bin:${PATH}"
ENV JENV_ROOT="/home/${USER}/.jenv"
ENV JENV_SHELL=bash

# ============================================================================
# INSTALL OPENCODE
# ============================================================================
RUN mkdir -p /home/${USER}/.opencode/bin && \
    ARCH=$(uname -m) && \
    if [ "${ARCH}" = "aarch64" ]; then \
        BINARY_ARCH="arm64"; \
    else \
        BINARY_ARCH="x64"; \
    fi && \
    # Determine download URL based on version
    if [ "${OPENCODE_VERSION}" = "latest" ]; then \
        DOWNLOAD_URL="https://github.com/anomalyco/opencode/releases/latest/download/opencode-linux-${BINARY_ARCH}.tar.gz"; \
    else \
        DOWNLOAD_URL="https://github.com/anomalyco/opencode/releases/download/v${OPENCODE_VERSION}/opencode-linux-${BINARY_ARCH}.tar.gz"; \
    fi && \
    # Download and install
    echo "Installing OpenCode ${OPENCODE_VERSION} for ${BINARY_ARCH}..." && \
    curl -fsSL "${DOWNLOAD_URL}" -o /tmp/opencode.tar.gz && \
    # NOTE: OpenCode CLI releases do not provide checksum verification files
    # This is a known limitation - consider verifying manually in production environments
    echo "WARNING: No checksum verification available for OpenCode CLI" && \
    tar -xzf /tmp/opencode.tar.gz -C /home/${USER}/.opencode/bin && \
    rm /tmp/opencode.tar.gz && \
    chmod +x /home/${USER}/.opencode/bin/opencode && \
    # Verify installation
    /home/${USER}/.opencode/bin/opencode --version || true

# Add OpenCode to PATH
ENV PATH="/home/${USER}/.opencode/bin:${PATH}"

# ============================================================================
# WORKSPACE SETUP
# ============================================================================
RUN mkdir -p /home/${USER}/workspace

WORKDIR /home/${USER}/workspace

# ============================================================================
# ENTRYPOINT CONFIGURATION
# ============================================================================
RUN echo '#!/bin/bash' > /home/${USER}/entrypoint.sh && \
    echo 'exec "$@"' >> /home/${USER}/entrypoint.sh && \
    chmod +x /home/${USER}/entrypoint.sh

ENTRYPOINT ["/home/opencode/entrypoint.sh", "opencode"]
