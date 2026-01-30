#!/usr/bin/env bash

# OpenCode AI Podman Build Script
set -euo pipefail

# Konfiguration
IMAGE_NAME="opencode-ai"
IMAGE_TAG="latest"
FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"

# Farben für Output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}OpenCode AI - Podman Image Builder${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Prüfen ob Podman installiert ist
if ! command -v podman &> /dev/null; then
    echo -e "${RED}Fehler: Podman ist nicht installiert!${NC}"
    echo "Bitte installiere Podman: brew install podman"
    exit 1
fi

echo -e "${GREEN}✓ Podman gefunden${NC}"
echo ""

# Prüfen ob Dockerfile existiert
if [ ! -f "Dockerfile" ]; then
    echo -e "${RED}Fehler: Dockerfile nicht gefunden!${NC}"
    exit 1
fi

echo -e "${BLUE}Baue Image: ${FULL_IMAGE_NAME}${NC}"
echo ""

# Image bauen
podman build \
    --tag "${FULL_IMAGE_NAME}" \
    --format docker \
    .

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Image erfolgreich gebaut!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Image Name: ${FULL_IMAGE_NAME}"
echo ""
echo "Zum Starten des Containers:"
echo "  podman run -it --rm -v \$(pwd):/home/opencode/workspace ${FULL_IMAGE_NAME}"
echo ""
echo "Mit OpenCode direkt starten:"
echo "  podman run -it --rm -v \$(pwd):/home/opencode/workspace ${FULL_IMAGE_NAME} opencode"
echo ""
