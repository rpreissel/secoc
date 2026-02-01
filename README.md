# secoc - Secure OpenCode AI Container

> Secure container environment for running OpenCode AI with Java, Node.js, Python, and Bun

**Security-hardened version with recent improvements - see [SECURITY.md](SECURITY.md)**

This project enables secure execution of OpenCode in a Podman container.

## 🚀 Quick Start

### Installation

```bash
# macOS
brew install podman

# Linux (Debian/Ubuntu)
sudo apt-get install podman

# Linux (RHEL/CentOS)
sudo yum install podman
```

### Usage

```bash
# Simple start
./seccode

# With specific workspace
./seccode /path/to/project

# With OpenCode parameters
./seccode --model claude-sonnet-4

# Force rebuild
./seccode --rebuild

# Use specific version
./seccode --version 0.5.0

# Skip update check
./seccode --no-update
```

**The script automatically handles:**
- ✓ Automatic version check against GitHub
- ✓ Automatic build on new OpenCode version
- ✓ Container start with all configurations
- ✓ Mounting of workspace, config, caches, Git, SSH

### Global Installation (Optional)

```bash
# System-wide installation (recommended)
sudo ln -s $(pwd)/seccode /usr/local/bin/seccode

# User-only installation
mkdir -p ~/.local/bin
ln -s $(pwd)/seccode ~/.local/bin/seccode
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

After installation, call from anywhere: `seccode`

## 📋 What gets mounted?

**OpenCode:**
- `~/.config/opencode` → Configuration and API keys
- `~/.local/share/opencode` → Data
- `~/.cache/opencode` → Cache

**Build Tools:**
- `~/.m2`, `~/.gradle`, `~/.npm`, `~/.cache/pip`, `~/.cache/bun`

**Git & SSH:**
- `~/.gitconfig`, `~/.config/git`, `~/.ssh` (read-only)

**Workspace:**
- Current directory or specified path

## 🔧 Configuration

### Configure OpenCode API Keys

```bash
# Create config directory
mkdir -p ~/.config/opencode

# Start OpenCode once for initial configuration
opencode

# See: https://opencode.ai/docs/configuration/
```

## 🔍 Troubleshooting

### Image is constantly being rebuilt
```bash
./seccode --no-update  # No auto-update
./seccode --version 0.5.0  # Specific version
```

### Container won't start
```bash
./seccode --rebuild  # Rebuild image
podman logs <container-id>  # Check logs
```

### OpenCode doesn't install
```bash
# Rebuild without cache
./seccode --rebuild
```

## 🔐 Security

- **Non-root user**: Container runs as user `opencode` (UID/GID customizable)
- **Minimal image**: Debian Bookworm Slim with minimal required packages
- **Secrets**: API keys are mounted via `~/.config/opencode`, never stored in image
- **Verified downloads**: GPG and SHA256 verification for all dependencies
- **Recent fixes**: Command injection protection, API rate limiting, path validation

**For detailed security information and vulnerability report process, see [SECURITY.md](SECURITY.md)**

### Custom UID/GID

```bash
# Build with custom UID/GID matching your host system
podman build \
  --build-arg UID=$(id -u) \
  --build-arg GID=$(id -g) \
  --tag secoc:latest .
```

---

**Version:** 3.0.0  
**Created:** 2026-01-20  
**Updated:** 2026-01-31  
**Focus:** Secure OpenCode in Podman with auto-update
