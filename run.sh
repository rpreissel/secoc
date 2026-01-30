#!/usr/bin/env bash

# OpenCode AI Podman Run Script
set -euo pipefail

# Konfiguration
IMAGE_NAME="opencode-ai"
IMAGE_TAG="latest"
FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"
CONTAINER_NAME="opencode-ai-$(date +%s)"

# Farben für Output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}OpenCode AI - Podman Container Starter${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Prüfen ob Podman installiert ist
if ! command -v podman &> /dev/null; then
    echo -e "${RED}Fehler: Podman ist nicht installiert!${NC}"
    echo "Bitte installiere Podman: brew install podman"
    exit 1
fi

echo -e "${GREEN}✓ Podman gefunden${NC}"

# Prüfen ob Image existiert
if ! podman image exists "${FULL_IMAGE_NAME}"; then
    echo -e "${RED}Fehler: Image '${FULL_IMAGE_NAME}' nicht gefunden!${NC}"
    echo "Bitte baue zuerst das Image: ./build.sh"
    exit 1
fi

echo -e "${GREEN}✓ Image gefunden${NC}"

# OpenCode Verzeichnisse
OPENCODE_CONFIG_DIR="${HOME}/.config/opencode"
OPENCODE_DATA_DIR="${HOME}/.local/share/opencode"
OPENCODE_STATE_DIR="${HOME}/.local/state/opencode"
OPENCODE_CACHE_DIR="${HOME}/.cache/opencode"

# Build Tool Caches
MAVEN_CACHE_DIR="${HOME}/.m2"
GRADLE_CACHE_DIR="${HOME}/.gradle"
NPM_CACHE_DIR="${HOME}/.npm"
PIP_CACHE_DIR="${HOME}/.cache/pip"
BUN_CACHE_DIR="${HOME}/.cache/bun"

# Git Config
GIT_CONFIG_FILE="${HOME}/.gitconfig"
GIT_CONFIG_DIR="${HOME}/.config/git"

# SSH Keys
SSH_DIR="${HOME}/.ssh"

# Verzeichnisse erstellen falls sie nicht existieren
mkdir -p "${OPENCODE_CONFIG_DIR}"
mkdir -p "${OPENCODE_DATA_DIR}"
mkdir -p "${OPENCODE_STATE_DIR}"
mkdir -p "${OPENCODE_CACHE_DIR}"
mkdir -p "${MAVEN_CACHE_DIR}"
mkdir -p "${GRADLE_CACHE_DIR}"
mkdir -p "${NPM_CACHE_DIR}"
mkdir -p "${PIP_CACHE_DIR}"
mkdir -p "${BUN_CACHE_DIR}"

echo -e "${GREEN}✓ Config-Verzeichnis: ${OPENCODE_CONFIG_DIR}${NC}"
echo -e "${GREEN}✓ Data-Verzeichnis: ${OPENCODE_DATA_DIR}${NC}"
echo -e "${GREEN}✓ State-Verzeichnis: ${OPENCODE_STATE_DIR}${NC}"
echo -e "${GREEN}✓ Cache-Verzeichnis: ${OPENCODE_CACHE_DIR}${NC}"
echo ""
echo -e "${BLUE}Build Tool Caches:${NC}"
echo -e "${GREEN}✓ Maven-Cache: ${MAVEN_CACHE_DIR}${NC}"
echo -e "${GREEN}✓ Gradle-Cache: ${GRADLE_CACHE_DIR}${NC}"
echo -e "${GREEN}✓ NPM-Cache: ${NPM_CACHE_DIR}${NC}"
echo -e "${GREEN}✓ Pip-Cache: ${PIP_CACHE_DIR}${NC}"
echo -e "${GREEN}✓ Bun-Cache: ${BUN_CACHE_DIR}${NC}"
echo ""

# Git Config prüfen
if [ -f "${GIT_CONFIG_FILE}" ]; then
    echo -e "${GREEN}✓ Git Config gefunden: ${GIT_CONFIG_FILE}${NC}"
else
    echo -e "${YELLOW}⚠ Git Config nicht gefunden unter ${GIT_CONFIG_FILE}${NC}"
fi

if [ -d "${GIT_CONFIG_DIR}" ]; then
    echo -e "${GREEN}✓ Git Config Dir gefunden: ${GIT_CONFIG_DIR}${NC}"
fi

# SSH Keys prüfen
if [ -d "${SSH_DIR}" ]; then
    echo -e "${GREEN}✓ SSH-Keys gefunden: ${SSH_DIR}${NC}"
else
    echo -e "${YELLOW}⚠ SSH-Keys nicht gefunden unter ${SSH_DIR}${NC}"
fi

# Workspace Verzeichnis (erstes Argument oder aktuelles Verzeichnis)
WORKSPACE_DIR="${1:-.}"
WORKSPACE_DIR="$(cd "${WORKSPACE_DIR}" && pwd)"  # Absolute Path ermitteln

# Wenn ein Workspace-Parameter angegeben wurde, entfernen wir ihn aus $@
if [ $# -gt 0 ] && [ -d "$1" ]; then
    shift
fi

echo -e "${GREEN}✓ Workspace: ${WORKSPACE_DIR}${NC}"
echo ""

echo -e "${BLUE}Starte OpenCode Container...${NC}"
echo -e "${YELLOW}Hinweis: Die erste Initialisierung kann 5-10 Sekunden dauern.${NC}"
echo ""

# SELinux-Labeling nur auf Linux verwenden
if [[ "$(uname -s)" == "Linux" ]]; then
    SELINUX_LABEL=":Z"
    SELINUX_LABEL_RO=":ro,Z"
else
    SELINUX_LABEL=""
    SELINUX_LABEL_RO=":ro"
fi

# Volume-Optionen vorbereiten
VOLUME_OPTS=(
    -v "${WORKSPACE_DIR}:/home/opencode/workspace${SELINUX_LABEL}"
    -v "${OPENCODE_CONFIG_DIR}:/home/opencode/.config/opencode${SELINUX_LABEL}"
    -v "${OPENCODE_DATA_DIR}:/home/opencode/.local/share/opencode${SELINUX_LABEL}"
    -v "${OPENCODE_STATE_DIR}:/home/opencode/.local/state/opencode${SELINUX_LABEL}"
    -v "${OPENCODE_CACHE_DIR}:/home/opencode/.cache/opencode${SELINUX_LABEL}"
    -v "${MAVEN_CACHE_DIR}:/home/opencode/.m2${SELINUX_LABEL}"
    -v "${GRADLE_CACHE_DIR}:/home/opencode/.gradle${SELINUX_LABEL}"
    -v "${NPM_CACHE_DIR}:/home/opencode/.npm${SELINUX_LABEL}"
    -v "${PIP_CACHE_DIR}:/home/opencode/.cache/pip${SELINUX_LABEL}"
    -v "${BUN_CACHE_DIR}:/home/opencode/.cache/bun${SELINUX_LABEL}"
)

# Git Config mounten wenn vorhanden
if [ -f "${GIT_CONFIG_FILE}" ]; then
    VOLUME_OPTS+=(-v "${GIT_CONFIG_FILE}:/home/opencode/.gitconfig${SELINUX_LABEL_RO}")
fi

if [ -d "${GIT_CONFIG_DIR}" ]; then
    VOLUME_OPTS+=(-v "${GIT_CONFIG_DIR}:/home/opencode/.config/git${SELINUX_LABEL_RO}")
fi

# SSH Keys mounten wenn vorhanden
if [ -d "${SSH_DIR}" ]; then
    VOLUME_OPTS+=(-v "${SSH_DIR}:/home/opencode/.ssh${SELINUX_LABEL_RO}")
fi

# Container starten mit Mounts
podman run -it --rm \
    --name "${CONTAINER_NAME}" \
    --network host \
    --cap-add=NET_RAW \
    "${VOLUME_OPTS[@]}" \
    "${FULL_IMAGE_NAME}" "$@"

echo ""
echo -e "${GREEN}Container beendet.${NC}"
