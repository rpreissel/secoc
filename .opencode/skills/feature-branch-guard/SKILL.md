---
name: feature-branch-guard
description: Ensures all git commits happen on feature branches, never on protected branches
trigger: before_commit
auto_run: true
---

# Feature Branch Guard

Execute BEFORE creating git commits.

## Config
Read protected branches from `.opencode/config.json` → `skills.feature-branch-guard.protected-branches` (default: `["main", "master"]`)

## Workflow

**1. Check current branch**

**2. If protected branch:**
- Inform user: "⚠️ On protected branch: {branch}"
- Extract from user prompt:
  - Ticket: `GH-123`, `JIRA-456`, `#789`, or `[A-Z]+-[0-9]+`
  - Type: "fix/bug" → `bugfix/`, "add/new" → `feature/`, "urgent" → `hotfix/`, default → `feature/`
  - Description: 2-4 key words, kebab-case
- Generate 2 branch name suggestions: `{type}/{ticket}-{description}`
- Ask user to choose (use `question` tool):
  - Option 1: First suggestion (Recommended)
  - Option 2: Second suggestion
  - Option 3: Commit directly on protected branch (NOT recommended)
  - Custom option available
- If user chooses protected branch: Proceed with commit on current branch
- Otherwise: Stash changes, create branch, restore changes, push if `config.auto-push` enabled
- Proceed with commit

**3. If feature branch:**
- Proceed directly with commit

## Commit Message Format

**If ticket number exists in branch name:**
- Extract ticket from branch name (pattern: `[A-Z]+-[0-9]+` or `GH-[0-9]+` or `#[0-9]+`)
- Prefix commit message with ticket: `{TICKET}: {commit message}`
- Example: Branch `bugfix/GH-123-login-bug` → Commit: `GH-123: Fix login validation bug`

**If no ticket in branch name:**
- Use commit message as is

## Example
User: "Fix login bug GH-123" on branch `main`
→ Extract: ticket=GH-123, type=bugfix, desc=login-bug
→ Suggest: `bugfix/GH-123-login-bug`, `feature/GH-123-fix-login`
→ User selects `bugfix/GH-123-login-bug`
→ Create branch
→ Commit message: `GH-123: Fix login validation bug`
