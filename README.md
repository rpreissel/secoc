# Secure OpenCode - OpenCode in Podman

Dieses Projekt ermöglicht es, OpenCode sicher in einem Podman-Container auszuführen.

## 🚀 Schnellstart

### Installation

```bash
# macOS
brew install podman

# Linux (Debian/Ubuntu)
sudo apt-get install podman

# Linux (RHEL/CentOS)
sudo yum install podman
```

### Benutzung

```bash
# Einfacher Start
./seccode

# Mit spezifischem Workspace
./seccode /path/to/project

# Mit OpenCode-Parametern
./seccode --model claude-sonnet-4

# Erzwungener Rebuild
./seccode --rebuild

# Spezifische Version verwenden
./seccode --version 0.5.0

# Update-Check überspringen
./seccode --no-update
```

**Das Skript übernimmt automatisch:**
- ✓ Automatische Version-Prüfung gegen GitHub
- ✓ Automatischer Build bei neuer OpenCode-Version
- ✓ Container-Start mit allen Konfigurationen
- ✓ Mounting von Workspace, Config, Caches, Git, SSH

### Globale Installation (Optional)

```bash
# System-weit installieren (empfohlen)
sudo ln -s $(pwd)/seccode /usr/local/bin/seccode

# Nur für aktuellen Benutzer
mkdir -p ~/.local/bin
ln -s $(pwd)/seccode ~/.local/bin/seccode
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

Danach von überall aufrufbar: `seccode`

## 📋 Was wird gemountet?

**OpenCode:**
- `~/.config/opencode` → Konfiguration und API-Keys
- `~/.local/share/opencode` → Daten
- `~/.cache/opencode` → Cache

**Build-Tools:**
- `~/.m2`, `~/.gradle`, `~/.npm`, `~/.cache/pip`, `~/.cache/bun`

**Git & SSH:**
- `~/.gitconfig`, `~/.config/git`, `~/.ssh` (read-only)

**Workspace:**
- Aktuelles Verzeichnis oder spezifizierter Pfad

## 🔧 Konfiguration

### OpenCode API-Keys einrichten

```bash
# Config-Verzeichnis erstellen
mkdir -p ~/.config/opencode

# OpenCode einmal starten zur initialen Konfiguration
opencode

# Siehe: https://opencode.ai/docs/configuration/
```

## 🔍 Troubleshooting

### Image wird ständig neu gebaut
```bash
./seccode --no-update  # Kein Auto-Update
./seccode --version 0.5.0  # Spezifische Version
```

### Container startet nicht
```bash
./seccode --rebuild  # Image neu bauen
podman logs <container-id>  # Logs prüfen
```

### OpenCode installiert sich nicht
```bash
# Build ohne Cache wiederholen
./seccode --rebuild
```

## 🔐 Sicherheit

- **Nicht-Root-User**: Container läuft als User `opencode`
- **Minimales Image**: Debian Bookworm Slim mit minimal notwendigen Paketen
- **Secrets**: API-Keys werden via `~/.config/opencode` gemountet, nie im Image gespeichert

---

**Version:** 3.0.0  
**Erstellt:** 2026-01-20  
**Aktualisiert:** 2026-01-31  
**Fokus:** Secure OpenCode in Podman mit Auto-Update
