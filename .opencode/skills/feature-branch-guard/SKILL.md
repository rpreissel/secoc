---
name: feature-branch-guard
description: Ensures all git commits happen on feature branches, never on protected branches
trigger: before_commit
auto_run: true
---

# Feature Branch Guard

Execute BEFORE creating git commits (including when user requests commit/push).

## Workflow

### 1. Check Current Branch
```bash
git branch --show-current
```

### 2. Read Protected Branches from Config
- Path: `.opencode/config.json`
- Key: `skills.feature-branch-guard.protected-branches`
- Default: `["main", "master"]`

### 3. If Protected Branch → Create Feature Branch

**3.1 Extract Info from User Prompt:**
- Ticket: `GH-123`, `JIRA-456`, `#789`, or `[A-Z]+-[0-9]+`
- Type: "fix/bug" → `bugfix/`, "add/new" → `feature/`, "urgent" → `hotfix/`, else `feature/`
- Description: Extract 2-4 key words, kebab-case

**3.2 Generate 2 Suggestions:**
- Format: `{type}/{ticket}-{description}` or `{type}/{description}`
- Examples: `bugfix/GH-456-login`, `feature/add-oauth`

**3.3 Ask User (use `question` tool):**
```
⚠️ On protected branch: {branch}. Choose feature branch:
1. {suggestion1} (Recommended)
2. {suggestion2}
3. [Custom]
```

**3.4 Create Branch:**
```bash
git stash push -m "WIP: Moving to feature branch"
git checkout -b {selected_name}
git stash pop
git push -u origin {selected_name}  # if config.auto-push enabled
```

**3.5 Proceed with Original Task**

### 4. If Feature Branch → Proceed Directly

## Error Handling
- Branch exists: `git checkout {name}` instead of create
- Not git repo: Ask user if should `git init`
- Stash conflicts: `git checkout stash@{0} -- .`

## Example
```
User: "Fix login bug GH-123"
→ Check branch: "main"
→ Inform: "⚠️ On protected branch: main"
→ Extract: ticket=GH-123, type=bugfix, desc=login-bug
→ Suggest: bugfix/GH-123-login-bug, feature/GH-123-fix-login
→ User selects option 1
→ Create branch, then fix bug
```
