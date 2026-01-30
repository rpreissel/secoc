# Projekt Agent-Regeln

## Branch Protection (MANDATORY)

**KRITISCH**: Vor JEDEM Git-Commit wird automatisch der Skill `commit-guard` ausgeführt.

Der Skill verhindert Commits auf protected branches (main/master) und erstellt automatisch Feature-Branches.

**Details:** Siehe `.opencode/skills/commit-guard/SKILL.md`

**Konfiguration:** `.opencode/config.json` → `skills.commit-guard`
