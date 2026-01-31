# Project Agent Rules

## Project Overview

**secoc** is a container-based DevOps tool for securely running OpenCode AI in a Podman environment.

**Tech Stack:**
- **Core:** Bash, Podman, Dockerfile
- **Container Base:** Debian Bookworm Slim
- **CI/CD:** GitHub Actions
- **Runtime:** Node.js 20.x, Bun, Python 3, Java (OpenJDK 17 + Temurin 21)

## Build/Test/Lint Commands

### Container Management

```bash
# Build image (or force rebuild)
./seccode --rebuild

# Start container (auto-update + build if needed)
./seccode                        # In current directory
./seccode /path/to/project      # With specific workspace

# Use specific OpenCode version
./seccode --version 0.5.0

# Skip update check
./seccode --no-update

# Start OpenCode with parameters
./seccode --model claude-sonnet-4
./seccode /path/to/project --model gpt-4
```

### Manual Container Tests

```bash
# Check image
podman images | grep opencode-ai

# Show container logs
podman logs <container-id>

# Interactive shell in container
podman run -it --rm opencode-ai:latest /bin/bash

# Dockerfile linting (optional, manual)
# hadolint Dockerfile  # If hadolint is installed
```

### Git & Release

```bash
# Check status
git status

# Commits with Conventional Commits format
git commit -m "feat: new feature"
git commit -m "fix: bugfix"
git commit -m "docs: documentation updated"
git commit -m "chore: maintenance work"

# Release is automatically created via GitHub Actions on push to main
git push origin main
```

**Note:** This project has no traditional unit/integration tests. Testing is done through:
- Manual container validation
- Real-world usage testing
- GitHub Actions CI/CD validation

## Code Style Guidelines

### Bash Script Style

#### File Structure
```bash
#!/usr/bin/env bash

# Script description
# Author/Purpose
set -euo pipefail  # MANDATORY: Strict error handling

# ============================================================================
# CONFIGURATION
# ============================================================================
IMAGE_NAME="opencode-ai"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================
print_success() {
    echo -e "${GREEN}✓ $1${NC}" >&2
}

# ============================================================================
# MAIN LOGIC
# ============================================================================
```

#### Naming Conventions
- **Variables:** `UPPER_CASE_WITH_UNDERSCORES` for global constants
- **Functions:** `snake_case_with_verbs` (e.g. `check_latest_version()`, `build_image()`)
- **Local Variables:** `lower_case` in functions
- **Files:** Lowercase with hyphens (e.g. `commit-guard`, `release.yml`)

#### Error Handling
```bash
# ALWAYS set -euo pipefail at the beginning
set -euo pipefail

# Catch errors
if ! command -v podman &> /dev/null; then
    print_error "Podman is not installed"
    exit 1
fi

# Safe commands
grep "pattern" file || true  # Prevent exit on non-zero
mkdir -p directory           # Safe directory creation
```

### Dockerfile Style

```dockerfile
# Combine related commands
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    package1 \
    package2 \
    && rm -rf /var/lib/apt/lists/*

# Sort packages alphabetically within categories
# ALWAYS use non-root user
# NO secrets in image - use Build Args or Volume Mounts
```

### Git Workflow

#### Conventional Commits (MANDATORY)
```
feat: New feature added
fix: Bug fixed
docs: Documentation updated
chore: Maintenance work, dependencies
refactor: Code restructuring
perf: Performance improvement
test: Tests added/modified
```

#### Branch Protection (via commit-guard skill)
- **Protected Branches:** `main`, `master`
- **Allowed Patterns:** `feature/*`, `bugfix/*`, `hotfix/*`
- **Auto-Push:** Enabled (after branch creation)
- **Max Files:** 15 per commit
- **Max Lines:** 500 changes per commit

## Filenames & Structure

### Naming Conventions
- **Executables:** Lowercase, no extension (`seccode`)
- **Documentation:** UPPERCASE with extension (`README.md`, `CHANGELOG.md`, `AGENTS.md`)
- **Config Files:** Lowercase with dot (`.gitignore`, `.dockerignore`)
- **Directories:** Lowercase with hyphens (`.opencode`, `commit-guard`)

### Directory Structure
```
/
├── .github/workflows/     # GitHub Actions
├── .opencode/             # OpenCode Config & Skills
│   ├── config.json
│   ├── package.json
│   └── skills/
├── Dockerfile             # Container Definition
├── seccode                # Main Executable
├── README.md              # User Documentation
├── AGENTS.md              # This File
└── CHANGELOG.md           # Auto-generated
```

## Branch Protection (MANDATORY)

**CRITICAL:** Before EVERY Git commit, the skill `commit-guard` is automatically executed.

### Automatic Checks
- Prevents direct commits to `main`/`master`
- Automatically creates feature branches if needed
- Validates commit size (max. 15 files, 500 lines)
- Checks branch name patterns

### Configuration
See `.opencode/config.json` → `skills.commit-guard`

**Details:** `.opencode/skills/commit-guard/SKILL.md`

## Best Practices

### 1. Script Development
- Begin ALWAYS with `set -euo pipefail`
- Use `"${VARIABLE}"` instead of `$VARIABLE` (Quote all variables)
- Check dependencies before usage
- Provide helpful error messages

### 2. Container Images
- Minimize layer count
- Sort packages alphabetically
- Remove temporary files in the same layer
- Use `--no-install-recommends` with apt-get

### 3. Versioning
- Use Conventional Commits for automatic versioning
- `feat:` → Minor Bump (0.x.0)
- `fix:` → Patch Bump (0.0.x)
- `BREAKING CHANGE:` → Major Bump (x.0.0)

### 4. Documentation
- English for all technical documentation and code comments
- All scripts need `--help` option
- Changelog is automatically generated

### 5. Git Hygiene
- One Feature = One Branch
- Atomic Commits (logically related changes)
- Meaningful commit messages
- NEVER push directly to `main` (enforced via commit-guard)
