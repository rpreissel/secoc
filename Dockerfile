# OpenCode AI Dockerfile for Podman
FROM docker.io/library/debian:bookworm-slim

# Security and Build Arguments
ARG USER=opencode
ARG UID=1000
ARG GID=1000
ARG OPENCODE_VERSION=latest

# Install system updates and developer tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # Base tools
    ca-certificates \
    curl \
    wget \
    bash \
    git \
    # Useful CLI tools
    jq \
    unzip \
    zip \
    vim \
    nano \
    # OpenCode-specific tools
    ripgrep \
    fd-find \
    # Python & Pip
    python3 \
    python3-pip \
    python3-venv \
    # Java Development Kit (OpenJDK 17)
    openjdk-17-jdk \
    # Java build tools
    maven \
    gradle \
    # Additional useful tools
    build-essential \
    make \
    procps \
    # Network tools
    iputils-ping \
    net-tools \
    dnsutils \
    netcat-openbsd \
    # SSH Client & Server
    openssh-client \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# Create symlinks for fd-find (fd is installed under a different name)
RUN ln -s /usr/bin/fdfind /usr/local/bin/fd

# Install OpenJDK 21 from Adoptium/Eclipse Temurin
RUN ARCH=$(dpkg --print-architecture) && \
    wget -O- https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/trusted.gpg.d/adoptium.asc && \
    echo "deb https://packages.adoptium.net/artifactory/deb bookworm main" | tee /etc/apt/sources.list.d/adoptium.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends temurin-21-jdk && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js LTS (20.x)
RUN ARCH=$(dpkg --print-architecture) && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Bun (fast JavaScript runtime & package manager)
RUN curl -fsSL https://bun.sh/install | bash && \
    ln -s /root/.bun/bin/bun /usr/local/bin/bun

# Make Python available as 'python'
RUN ln -sf /usr/bin/python3 /usr/local/bin/python

# Create non-root user for security
RUN groupadd -g ${GID} ${USER} && \
    useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER}

# Switch to new user
USER ${USER}
WORKDIR /home/${USER}

# Install jenv for Java version management
RUN git clone https://github.com/jenv/jenv.git ~/.jenv && \
    echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(jenv init -)"' >> ~/.bashrc && \
    echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.profile && \
    echo 'eval "$(jenv init -)"' >> ~/.profile

# Configure jenv and add Java versions
RUN bash -c 'export PATH="$HOME/.jenv/bin:$PATH" && eval "$(jenv init -)" && \
    jenv add /usr/lib/jvm/java-17-openjdk-* && \
    jenv add /usr/lib/jvm/temurin-21-jdk-* && \
    jenv global 21 && \
    jenv enable-plugin export' && \
    echo 'export PATH="$HOME/.jenv/shims:$HOME/.jenv/bin:$PATH"' >> /home/${USER}/.jenv_init && \
    echo 'export JENV_SHELL=bash' >> /home/${USER}/.jenv_init && \
    echo 'export JENV_LOADED=1' >> /home/${USER}/.jenv_init

# Make all important tools available in PATH
ENV PATH="/home/${USER}/.jenv/shims:/home/${USER}/.jenv/bin:${PATH}"
ENV JENV_ROOT="/home/${USER}/.jenv"
ENV JENV_SHELL=bash

# Install OpenCode directly
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

# Ensure OpenCode and all tools are in PATH
ENV PATH="/home/${USER}/.opencode/bin:${PATH}"

# Create workspace directory
RUN mkdir -p /home/${USER}/workspace

WORKDIR /home/${USER}/workspace

# Simple entrypoint script
RUN echo '#!/bin/bash' > /home/${USER}/entrypoint.sh && \
    echo 'exec "$@"' >> /home/${USER}/entrypoint.sh && \
    chmod +x /home/${USER}/entrypoint.sh

# Start OpenCode directly
ENTRYPOINT ["/home/opencode/entrypoint.sh", "opencode"]
