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

# Prüfen ob OpenCode Config existiert, sonst Warnung
if [ ! -d "${OPENCODE_CONFIG_DIR}" ]; then
    echo -e "${YELLOW}⚠ Warnung: OpenCode Config nicht gefunden unter ${OPENCODE_CONFIG_DIR}${NC}"
    echo -e "${YELLOW}  Das Config-Verzeichnis wird beim ersten Start erstellt.${NC}"
fi

# Prüfen ob OpenCode Data existiert, sonst Warnung
if [ ! -d "${OPENCODE_DATA_DIR}" ]; then
    echo -e "${YELLOW}⚠ Warnung: OpenCode Data nicht gefunden unter ${OPENCODE_DATA_DIR}${NC}"
    echo -e "${YELLOW}  Das Data-Verzeichnis (für Provider Credentials) wird beim ersten Start erstellt.${NC}"
fi

echo -e "${GREEN}✓ Config-Verzeichnis: ${OPENCODE_CONFIG_DIR}${NC}"
echo -e "${GREEN}✓ Data-Verzeichnis: ${OPENCODE_DATA_DIR}${NC}"

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
echo ""

# Container starten mit Mounts
podman run -it --rm \
    --name "${CONTAINER_NAME}" \
    -v "${WORKSPACE_DIR}:/home/opencode/workspace:Z" \
    -v "${OPENCODE_CONFIG_DIR}:/home/opencode/.config/opencode:Z" \
    -v "${OPENCODE_DATA_DIR}:/home/opencode/.local/share/opencode:Z" \
    "${FULL_IMAGE_NAME}" "$@"

echo ""
echo -e "${GREEN}Container beendet.${NC}"
