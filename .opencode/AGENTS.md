# Projekt Agent-Regeln

## Branch Protection (MANDATORY)

**KRITISCH**: Vor JEDER Code-Änderung (Edit/Write) oder Commit:

1. **Branch prüfen:**
   ```bash
   git branch --show-current
   ```

2. **Wenn protected branch (main/master/develop/staging):**
   - ⚠️ User informieren: "Du bist auf protected branch: {branch}"
   - Ticket-Nummer extrahieren aus User-Prompt (GH-*, JIRA-*, #*)
   - Branch-Namen generieren:
     * Mit Ticket: `{type}/{ticket}-{description}` (z.B. `feature/GH-123-add-auth`)
     * Ohne Ticket: `{type}/{description}` (z.B. `bugfix/fix-login`)
     * Type: "fix" → bugfix/, "add" → feature/, "urgent" → hotfix/
   - User 2-3 Vorschläge geben + Custom-Option
   - Branch erstellen:
     ```bash
     git stash push -m "WIP: Moving to feature branch"
     git checkout -b {branch_name}
     git stash pop
     git push -u origin {branch_name}
     ```
   - Dann mit Original-Task fortfahren

3. **Wenn feature branch:**
   - Direkt mit Task fortfahren

**Config:** Lies protected-branches aus `.opencode/config.json` → `skills.feature-branch-guard.protected-branches`

**Error Handling:**
- Branch exists: `git checkout {branch_name}` statt create
- No git repo: User fragen ob `git init`
- No gh CLI: Manual naming (kein Problem)

**NIEMALS** Code auf protected branches ändern oder committen!
