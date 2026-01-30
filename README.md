# Secure OpenCode - OpenCode in Docker/Podman

Dieses Projekt ermöglicht es, OpenCode sicher in einem Docker- oder Podman-Container auszuführen.

## 📁 Verzeichnisstruktur

```
.
├── .opencode/                     # OpenCode Konfiguration
│   ├── AGENTS.md                 # Agent-Regeln (Branch Protection)
│   └── config.json               # Projekt-Config
│
├── Dockerfile                     # Container-Definition
├── build.sh                       # Build-Skript für Container-Image
├── run.sh                         # Start-Skript für Container
└── README.md                      # Diese Datei
```

## 🚀 Schnellstart

### Voraussetzungen

**Container-Runtime:**
- Podman (empfohlen) oder Docker
- macOS: `brew install podman`
- Linux (Debian/Ubuntu): `sudo apt-get install podman`
- Linux (RHEL/CentOS): `sudo yum install podman`

### 1. Container-Image bauen

```bash
./build.sh
```

Das Skript:
- Prüft ob Podman installiert ist
- Baut das Container-Image mit dem Namen `opencode-ai:latest`
- Verwendet einen Nicht-Root-User für erhöhte Sicherheit

### 2. Container starten

```bash
./run.sh
```

Das Skript:
- Mountet das aktuelle Verzeichnis als Workspace
- Mountet die OpenCode-Konfiguration aus `~/.config/opencode`
- Startet OpenCode interaktiv im Container

### 3. Manueller Start (optional)

```bash
# Mit Podman
podman run -it --rm \
  -v $(pwd):/home/opencode/workspace:Z \
  -v ~/.config/opencode:/home/opencode/.config/opencode:Z \
  opencode-ai:latest

# Mit Docker
docker run -it --rm \
  -v $(pwd):/home/opencode/workspace \
  -v ~/.config/opencode:/home/opencode/.config/opencode \
  opencode-ai:latest
```

## 📋 Container-Details

### Dockerfile

Das Dockerfile basiert auf Debian Bookworm Slim und:
- Verwendet einen Nicht-Root-User (`opencode`) für erhöhte Sicherheit
- Installiert nur minimal notwendige Pakete (ca-certificates, curl, bash, git)
- Installiert OpenCode über das offizielle Installationsskript
- Setzt ein Workspace-Verzeichnis für Projekte

### Build-Argumente

```bash
# Benutzername ändern (default: opencode)
podman build --build-arg USER=myuser --tag opencode-ai:latest .

# UID/GID anpassen (default: 1000/1000)
podman build --build-arg UID=1001 --build-arg GID=1001 --tag opencode-ai:latest .
```

## 🔧 Konfiguration

### OpenCode Config

Die OpenCode-Konfiguration wird aus `~/.config/opencode` in den Container gemountet. So kannst du:
- Deine API-Keys und Provider-Einstellungen nutzen
- Projekt-spezifische Configs verwenden
- Die Konfiguration außerhalb des Containers verwalten

**Erste Konfiguration:**
```bash
# OpenCode Config-Verzeichnis erstellen (falls noch nicht vorhanden)
mkdir -p ~/.config/opencode

# OpenCode einmal lokal starten, um initiale Config zu erstellen
opencode

# Oder manuell eine Config erstellen
# Siehe: https://opencode.ai/docs/configuration/
```

## 🔍 Erweiterte Nutzung

### Umgebungsvariablen weitergeben

```bash
# API-Keys als Umgebungsvariablen setzen
podman run -it --rm \
  -e OPENAI_API_KEY="sk-..." \
  -e ANTHROPIC_API_KEY="..." \
  -v $(pwd):/home/opencode/workspace:Z \
  opencode-ai:latest
```

### Eigenen Workspace mounten

```bash
# Anderes Verzeichnis als Workspace verwenden
podman run -it --rm \
  -v /path/to/your/project:/home/opencode/workspace:Z \
  opencode-ai:latest
```

### Container mit Shell starten

```bash
# Bash-Shell im Container öffnen (für Debugging)
podman run -it --rm \
  -v $(pwd):/home/opencode/workspace:Z \
  --entrypoint /bin/bash \
  opencode-ai:latest
```

### Persistente Container-Instanz

```bash
# Container mit Namen erstellen (nicht mit --rm)
podman run -it \
  --name my-opencode \
  -v $(pwd):/home/opencode/workspace:Z \
  opencode-ai:latest

# Später wieder starten
podman start -ai my-opencode

# Container löschen
podman rm my-opencode
```

## 🔍 Troubleshooting

### Fehler: "Podman not found"
**Lösung:**
```bash
# macOS
brew install podman

# Linux (Debian/Ubuntu)
sudo apt-get install podman

# Linux (RHEL/CentOS)
sudo yum install podman
```

### Fehler: "Permission denied" beim Volume-Mount
**Lösung:**
- Bei Podman: Das `:Z` Flag am Ende des Volume-Mounts nutzt SELinux-Relabeling
- Bei Docker: `:Z` Flag kann weggelassen werden
- Stelle sicher, dass das gemountete Verzeichnis lesbar ist

### Container startet nicht
**Lösung:**
```bash
# Image neu bauen
./build.sh

# Logs anschauen
podman logs <container-id>

# Container-Shell öffnen für Debugging
podman run -it --rm --entrypoint /bin/bash opencode-ai:latest
```

### OpenCode installiert sich nicht
**Lösung:**
- Prüfe Internetverbindung während des Builds
- Build mit `--no-cache` wiederholen:
  ```bash
  podman build --no-cache --tag opencode-ai:latest .
  ```

## 🔐 Sicherheit

### Container-Sicherheit

Das Projekt implementiert mehrere Sicherheits-Best-Practices:

- **Nicht-Root-User**: Container läuft mit dediziertem User (`opencode`)
- **Minimales Base-Image**: Debian Bookworm Slim reduziert Angriffsfläche
- **Nur notwendige Pakete**: Minimale Installation nur erforderlicher Tools
- **Read-Only-Container** (optional):
  ```bash
  podman run -it --rm --read-only \
    -v $(pwd):/home/opencode/workspace:Z \
    opencode-ai:latest
  ```

### Secrets Management

**Wichtig:** Niemals Secrets in den Container backen!

**Empfohlene Methoden:**
1. **Umgebungsvariablen** (für CI/CD):
   ```bash
   podman run -it --rm \
     -e OPENAI_API_KEY="$OPENAI_API_KEY" \
     opencode-ai:latest
   ```

2. **Volume-Mount der Config** (empfohlen für lokale Entwicklung):
   ```bash
   # Config liegt in ~/.config/opencode
   # Wird automatisch vom run.sh gemountet
   ./run.sh
   ```

3. **Podman Secrets** (für Production):
   ```bash
   # Secret erstellen
   echo "sk-..." | podman secret create openai_key -
   
   # Container mit Secret starten
   podman run -it --rm \
     --secret openai_key,type=env,target=OPENAI_API_KEY \
     opencode-ai:latest
   ```

### .gitignore

Das Projekt enthält eine `.gitignore` die verhindert, dass sensitive Daten committed werden.

## 📚 Weiterführende Dokumentation

- [OpenCode Dokumentation](https://opencode.ai/docs/)
- [Podman Dokumentation](https://docs.podman.io/)
- [Docker Dokumentation](https://docs.docker.com/)
- [OpenCode GitHub Repository](https://github.com/anomalyco/opencode)

## 🛡️ Branch Protection

Dieses Projekt nutzt **OpenCode Agent-Regeln** für automatischen Branch-Schutz.

### Was macht es?

OpenCode verhindert automatisch direkte Code-Änderungen auf geschützten Branches:
- Automatische Branch-Prüfung vor jeder Code-Änderung
- Intelligente Feature-Branch-Erstellung mit Ticket-Integration
- GitHub/Jira Ticket-Nummer-Extraktion (GH-*, JIRA-*, #*)
- Automatischer Push zum Remote
- Graceful Handling von uncommitted Changes

### Wie es funktioniert

Die Branch-Protection ist in `.opencode/AGENTS.md` definiert und wird automatisch bei jedem OpenCode-Start geladen.

**Geschützte Branches:** `main`, `master` (konfigurierbar in `.opencode/config.json`)

### Konfiguration

Anpassen der geschützten Branches in `.opencode/config.json`:

```json
{
  "skills": {
    "feature-branch-guard": {
      "protected-branches": ["main", "master", "develop"],
      "auto-push": true
    }
  }
}
```

### Beispiel

```bash
# Du bist auf main
git checkout main

# OpenCode erkennt automatisch protected branch
# und führt dich durch Feature-Branch-Erstellung
opencode
> "Add authentication feature"

# OpenCode erstellt z.B. feature/add-authentication
# und pusht zum Remote
```

---

## 🤝 Support

Bei Problemen:
1. Prüfe die Container-Logs: `podman logs <container-id>`
2. Führe Build mit `--no-cache` aus
3. Öffne ein Issue im Repository
4. Siehe [OpenCode Dokumentation](https://opencode.ai/docs/)

## 📄 Lizenz

Dieses Projekt ist Open Source und kann frei verwendet werden.

---

**Version:** 2.0.0  
**Erstellt:** 2026-01-20  
**Aktualisiert:** 2026-01-30  
**Fokus:** Secure OpenCode in Docker/Podman
