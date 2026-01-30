# GitHub Enterprise Copilot - OpenCode Integration Tests

Dieses Verzeichnis enthält Test-Skripte und Konfigurationen zur Integration von GitHub Enterprise Copilot als LLM-Provider in OpenCode.

## 📁 Verzeichnisstruktur

```
.
├── test-configs/           # Konfigurationsdateien
│   ├── test-env.sh        # Template für Umgebungsvariablen
│   ├── variant-a.json     # Config-Variante A: GitHub Copilot Override
│   ├── variant-b.json     # Config-Variante B: OpenAI-compatible Custom
│   └── variant-c.json     # Config-Variante C: Anthropic Proxy
│
├── test-scripts/          # Test-Skripte
│   ├── 01-test-auth.sh           # API-Erreichbarkeit & Auth
│   ├── 02-test-models.sh         # Modellverfügbarkeit
│   ├── 03-test-simple-query.sh   # Einfache Chat-Anfrage
│   └── 04-test-code-gen.sh       # Code-Generierung
│
└── test-results/          # Test-Ergebnisse (automatisch erstellt)
    ├── test-01-*.log
    ├── test-02-*.log
    ├── generated-config-*.json
    └── generated-*.py/ts/sh
```

## 🚀 Schnellstart

### 1. Umgebung konfigurieren

```bash
# Kopiere die Umgebungs-Template
cp test-configs/test-env.sh test-configs/test-env.local.sh

# Bearbeite die Konfiguration mit deinen Werten
nano test-configs/test-env.local.sh
```

**Minimale Konfiguration in `test-env.local.sh`:**
```bash
export GITHUB_ENTERPRISE_URL="https://github.your-company.com"
export GITHUB_ENTERPRISE_TOKEN="ghp_XXXXXXXXXXXXX"
```

### 2. Umgebung laden

```bash
source test-configs/test-env.local.sh
```

### 3. Tests ausführen

```bash
# Test 01: API-Erreichbarkeit & Authentifizierung
./test-scripts/01-test-auth.sh

# Test 02: Verfügbare Modelle ermitteln
./test-scripts/02-test-models.sh

# Test 03: Einfache Chat-Anfrage
./test-scripts/03-test-simple-query.sh

# Test 04: Code-Generierung testen
./test-scripts/04-test-code-gen.sh
```

**Oder alle Tests nacheinander:**
```bash
./test-scripts/01-test-auth.sh && \
./test-scripts/02-test-models.sh && \
./test-scripts/03-test-simple-query.sh && \
./test-scripts/04-test-code-gen.sh
```

## 📋 Voraussetzungen

### GitHub Enterprise Server
- GitHub Enterprise Server mit aktiviertem Copilot
- Zugriff auf die GHE-Instanz
- Personal Access Token mit `copilot` Scope

### Personal Access Token erstellen

1. Gehe zu: `https://[DEINE-GHE-URL]/settings/tokens`
2. Klicke auf "Generate new token (classic)"
3. Name: `OpenCode Integration Test`
4. Scopes auswählen:
   - ✅ `copilot`
   - ✅ `read:org` (optional, für erweiterte Tests)
5. Token generieren und kopieren
6. In `test-env.local.sh` eintragen

### System-Anforderungen
- `bash` (Version 4.0+)
- `curl`
- `jq` (empfohlen für JSON-Parsing)

**jq installieren:**
```bash
# macOS
brew install jq

# Linux (Debian/Ubuntu)
sudo apt-get install jq

# Linux (RHEL/CentOS)
sudo yum install jq
```

## 🔧 Konfigurationsvarianten

### Variante A: GitHub Copilot mit URL Override
**Datei:** `test-configs/variant-a.json`

Nutzt die native GitHub Copilot Integration von OpenCode und überschreibt nur die URL.

**Vorteile:**
- Minimale Konfiguration
- Nutzt bestehende OpenCode-Features
- OAuth-Unterstützung

**Nachteile:**
- Weniger Kontrolle über API-Parameter

### Variante B: OpenAI-compatible Custom Provider (Empfohlen)
**Datei:** `test-configs/variant-b.json`

Vollständig angepasster Provider mit OpenAI-kompatiblem SDK.

**Vorteile:**
- Maximale Kontrolle über alle Parameter
- Eigene Modell-Limits definierbar
- Custom Headers möglich

**Nachteile:**
- Mehr Konfigurationsaufwand

### Variante C: Anthropic Provider als Proxy
**Datei:** `test-configs/variant-c.json`

Verwendet das Anthropic SDK falls GHE eine native Anthropic-API bietet.

**Vorteile:**
- Optimiert für Claude-Modelle
- Native Anthropic-Features

**Nachteile:**
- Nur relevant wenn GHE Anthropic-API hat

## 📊 Test-Beschreibungen

### Test 01: API-Erreichbarkeit & Authentifizierung
**Was wird getestet:**
- GHE-Instanz Erreichbarkeit
- GitHub API v3 Basis-Endpunkt
- Verschiedene Copilot API-Endpunkte
- Token-Berechtigungen und Scopes

**Erwartetes Ergebnis:**
- Mindestens ein funktionierender Copilot-Endpunkt
- Token mit `copilot` Scope verifiziert

### Test 02: Modellverfügbarkeit
**Was wird getestet:**
- Welche Modelle in GHE verfügbar sind
- API-Endpunkte für Modellabfragen
- Generierung einer OpenCode-Config basierend auf Modellen

**Erwartetes Ergebnis:**
- Liste verfügbarer Modelle
- Auto-generierte OpenCode-Konfiguration

### Test 03: Einfache Chat-Anfrage
**Was wird getestet:**
- Chat-Completion API Funktionalität
- Response-Struktur und -Format
- Latenz und Performance

**Erwartetes Ergebnis:**
- Erfolgreiche Chat-Anfrage
- Funktionierende AI-Responses

### Test 04: Code-Generierung
**Was wird getestet:**
- Code-Generierung für Python, TypeScript, Bash
- Multi-Turn Konversationen
- Streaming-Responses (optional)
- Code-Qualität

**Erwartetes Ergebnis:**
- Funktionale Code-Generierung
- Qualitätsscore ≥ 75/100

## 🔍 Troubleshooting

### Fehler: "401 Unauthorized"
**Lösung:**
- Token abgelaufen → Neuen Token erstellen
- Falscher Token → Token in `test-env.local.sh` prüfen
- Fehlende Scopes → Token mit `copilot` Scope neu erstellen

### Fehler: "404 Not Found"
**Lösung:**
- Falscher API-Endpunkt → Test 01 zeigt funktionierende Endpunkte
- Copilot nicht aktiviert → GHE-Admin kontaktieren

### Fehler: "Keine Modelle gefunden"
**Lösung:**
- Copilot-Konfiguration in GHE prüfen
- Berechtigung für Modelle prüfen
- GHE-Version aktualisieren (falls möglich)

### VPN-Probleme
**Lösung:**
```bash
# Proxy-Einstellungen in curl testen
export https_proxy=http://proxy.company.com:8080
export http_proxy=http://proxy.company.com:8080
```

## 📝 Nach den Tests

### 1. Erfolgreiche Tests
Wenn alle Tests erfolgreich waren:

```bash
# Wähle eine Config-Variante (B ist empfohlen)
cp test-configs/variant-b.json ~/.config/opencode/opencode.json

# Oder verwende die auto-generierte Config
cp test-results/generated-config-*.json ~/.config/opencode/opencode.json

# Ersetze Platzhalter mit echten Werten
sed -i 's|${GITHUB_ENTERPRISE_URL}|https://github.your-company.com|g' \
    ~/.config/opencode/opencode.json
sed -i 's|${GHE_COPILOT_ENDPOINT}|https://github.your-company.com/api/v3/copilot|g' \
    ~/.config/opencode/opencode.json
```

### 2. OpenCode starten

```bash
# Setze Environment-Variable für Token
export GITHUB_ENTERPRISE_TOKEN="ghp_XXXXXXXXXXXXX"

# Starte OpenCode
opencode

# Im OpenCode:
# - /models ausführen
# - Modell auswählen
# - Loslegen!
```

### 3. Integration validieren

Teste in OpenCode mit folgenden Anfragen:
```
What is the capital of France?

Write a Python function that sorts a list of numbers

Explain how async/await works in JavaScript
```

## 🔐 Sicherheit

### .gitignore
Füge zu deiner `.gitignore` hinzu:
```
test-configs/test-env.local.sh
test-results/
*.log
```

### Secrets Management
**Niemals committen:**
- `test-env.local.sh` (enthält Token)
- Personal Access Tokens
- API Keys

**Für Team-Nutzung:**
- Verwende Secret Management (z.B. 1Password, HashiCorp Vault)
- Oder CI/CD Secrets für automatisierte Tests

## 📚 Weiterführende Dokumentation

- [OpenCode Provider Dokumentation](https://opencode.ai/docs/providers/)
- [GitHub Enterprise Copilot Docs](https://docs.github.com/en/enterprise-server/copilot)
- [OpenCode GitHub Integration](https://opencode.ai/docs/github/)

## 🤝 Support

Bei Problemen:
1. Prüfe die Test-Logs in `test-results/`
2. Führe Tests mit `TEST_VERBOSE=true` aus
3. Öffne ein Issue im OpenCode Repository
4. Kontaktiere deinen GitHub Enterprise Administrator

## 📄 Lizenz

Diese Test-Skripte sind Open Source und können frei verwendet werden.

---

**Version:** 1.0.0  
**Erstellt:** 2026-01-20  
**Autor:** OpenCode Integration Team
