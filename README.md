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
├── seccode                        # Vereinigtes Build- und Run-Skript mit Auto-Update
└── README.md                      # Diese Datei
```

## 🚀 Schnellstart

### Voraussetzungen

**Container-Runtime:**
- Podman (empfohlen) oder Docker
- macOS: `brew install podman`
- Linux (Debian/Ubuntu): `sudo apt-get install podman`
- Linux (RHEL/CentOS): `sudo yum install podman`

### Einfachste Nutzung - Alles in einem Befehl!

```bash
./seccode
```

Das ist alles! Das `seccode` Skript übernimmt:
- ✓ Automatische Version-Prüfung gegen GitHub
- ✓ Automatischer Build bei neuer OpenCode-Version
- ✓ Intelligente Erkennung ob Rebuild nötig ist
- ✓ Container-Start mit allen Konfigurationen
- ✓ Mounting von Workspace, Config, Caches, Git, SSH

### Globale Installation (Optional - von überall aufrufbar)

Um `seccode` von überall im System aufrufen zu können:

```bash
# Option 1: System-weit installieren (empfohlen, benötigt sudo)
sudo ln -s $(pwd)/seccode /usr/local/bin/seccode

# Option 2: Nur für aktuellen Benutzer (kein sudo nötig)
mkdir -p ~/.local/bin
ln -s $(pwd)/seccode ~/.local/bin/seccode
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc  # oder ~/.zshrc
source ~/.bashrc  # oder source ~/.zshrc

# Danach von überall verwendbar:
cd ~/any/directory
seccode
seccode /path/to/project --model claude-sonnet-4
```

**Vorteile der globalen Installation:**
- Von jedem Verzeichnis aus aufrufbar
- Kein `./` Präfix mehr nötig
- Einfacherer Workflow
- Skript findet Dockerfile automatisch

### Weitere Nutzungsbeispiele

```bash
# Start im aktuellen Verzeichnis (Standard)
./seccode

# Start mit spezifischem Workspace
./seccode /path/to/project

# Mit OpenCode-Parametern
./seccode --model claude-sonnet-4

# Workspace + OpenCode-Parameter kombiniert
./seccode /path/to/project --model claude-sonnet-4

# Erzwungener Rebuild (z.B. nach Dockerfile-Änderung)
./seccode --rebuild

# Spezifische OpenCode-Version verwenden
./seccode --version 0.5.0

# Update-Check überspringen (nutzt vorhandenes Image)
./seccode --no-update

# Hilfe anzeigen
./seccode --help
```

### Auto-Update Funktion

Das `seccode` Skript prüft bei **jedem Start** automatisch:
- Gibt es eine neuere OpenCode-Version auf GitHub?
- Stimmt die installierte Version mit der neuesten überein?
- Falls nicht: Automatischer Rebuild mit neuer Version

**Kein manuelles Update mehr nötig!** Das Skript hält OpenCode immer aktuell.

### Manuelle Kontrolle (Optional)

Falls du die automatische Update-Funktion nicht möchtest:

```bash
# Baue Image manuell mit spezifischer Version
OPENCODE_VERSION=0.5.0 podman build --tag opencode-ai:latest .

# Starte ohne Update-Check
./seccode --no-update
```

## 📋 Container-Details

### Was wird automatisch gemountet?

Das `seccode` Skript mountet automatisch:

**OpenCode-Verzeichnisse:**
- `~/.config/opencode` → Konfiguration und API-Keys
- `~/.local/share/opencode` → Daten
- `~/.local/state/opencode` → Zustand
- `~/.cache/opencode` → Cache

**Build-Tool Caches (für schnellere Builds):**
- `~/.m2` → Maven Cache
- `~/.gradle` → Gradle Cache
- `~/.npm` → NPM Cache
- `~/.cache/pip` → Python Pip Cache
- `~/.cache/bun` → Bun Cache

**Git & SSH Integration:**
- `~/.gitconfig` → Git-Konfiguration (read-only)
- `~/.config/git` → Git-Verzeichnis (read-only)
- `~/.ssh` → SSH-Keys für Git-Authentifizierung (read-only)

**Workspace:**
- Aktuelles Verzeichnis oder spezifizierter Pfad

### Dockerfile

Das Dockerfile basiert auf Debian Bookworm Slim und:
- Verwendet einen Nicht-Root-User (`opencode`) für erhöhte Sicherheit
- Installiert nur minimal notwendige Pakete (ca-certificates, curl, bash, git)
- Installiert OpenCode über das offizielle Installationsskript
- Setzt ein Workspace-Verzeichnis für Projekte
- Speichert die OpenCode-Version im Image-Label für Auto-Update

### Build-Argumente

```bash
# Benutzername ändern (default: opencode)
podman build --build-arg USER=myuser --tag opencode-ai:latest .

# UID/GID anpassen (default: 1000/1000)
podman build --build-arg UID=1001 --build-arg GID=1001 --tag opencode-ai:latest .

# Spezifische OpenCode-Version (wird automatisch gesetzt)
podman build --build-arg OPENCODE_VERSION=0.5.0 --tag opencode-ai:latest .
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
# Image neu bauen erzwingen
./seccode --rebuild

# Logs anschauen
podman logs <container-id>

# Container-Shell öffnen für Debugging
podman run -it --rm --entrypoint /bin/bash opencode-ai:latest
```

### OpenCode installiert sich nicht
**Lösung:**
- Prüfe Internetverbindung während des Builds
- Build mit `--rebuild` und ohne Cache wiederholen:
  ```bash
  ./seccode --rebuild
  ```
- Oder manuell:
  ```bash
  podman build --no-cache --tag opencode-ai:latest .
  ```

### Image wird ständig neu gebaut
**Lösung:**
- Wenn du kein Auto-Update möchtest, nutze `--no-update`:
  ```bash
  ./seccode --no-update
  ```
- Oder verwende eine spezifische Version:
  ```bash
  ./seccode --version 0.5.0
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

**Version:** 3.0.0  
**Erstellt:** 2026-01-20  
**Aktualisiert:** 2026-01-31  
**Fokus:** Secure OpenCode in Podman mit Auto-Update
