---
name: commit-guard
description: Ensures commits are focused, appropriately sized, and on feature branches
trigger: before_commit
auto_run: true
---

# Commit Guard

Execute BEFORE creating git commits. Combines size checking, coherence analysis, and branch protection.

## Config
Read from `.opencode/config.json` → `skills.commit-guard` (defaults shown):
- `max-files`: 15, `max-lines`: 500, `max-file-lines`: 300
- `similarity-threshold`: 0.3, `auto-split`: true, `warning-only`: true
- `protected-branches`: ["main", "master"]
- `auto-push`: true, `branch-name-max-length`: 50

## Workflow

**1. Analyze:** Run `git diff --cached --numstat`, count files/lines, group by directory/type/naming

**2. Check thresholds:** Files/lines/single-file > limits → Warn

**3. Calculate coherence (0.0-1.0):** Same dir +0.4, same type +0.2, related names +0.3

**4. Determine strategy:**

**Unrelated (coherence < 0.3):**
- Show groups, ask to split
- If yes: Each group → separate feature branch (use `question` tool per group)
- For each: Stash all, create branch, restore group files only, commit, push individually
- Result: N parallel branches

**Related (coherence >= 0.3) with size warnings:**
- Ask to split into smaller commits
- If yes: Ask for branch ONCE, create branch, multiple commits on SAME branch, push once
- Result: 1 branch with N commits

**No warnings or declined split:**
- Single commit on current/new branch

**Branch creation (if on protected branch):**
- Extract: Ticket (`GH-123`, `JIRA-456`, `#789`), Type (fix→bugfix/, add→feature/, urgent→hotfix/), Description (group context or 2-4 words)
- Generate 2 suggestions: `{type}/{ticket}-{description}`
- User chooses (use `question` tool): Suggestion 1 (Recommended), Suggestion 2, Protected branch (NOT recommended), Custom

**Commit message:**
- If ticket in branch: Prefix with `{TICKET}: {message}`
- Unrelated: Distinct messages per group
- Related: Consistent message series

## Examples

**Unrelated → 3 Branches:**
```
auth/login.ts, ui/button.css, docs/README.md → Coherence 0.15
→ feature/auth-login: "Fix login authentication"
→ feature/ui-button-style: "Update button styling"
→ feature/docs-readme: "Update README"
```

**Related Large → 1 Branch:**
```
api/service.ts (600), service.test.ts (150), api.d.ts (50) → Coherence 0.9, 800 lines
→ feature/api-service-refactor:
  "Refactor API service implementation"
  "Add tests for API service refactor"
  "Update API type definitions"
```

**Clean → Direct:**
```
Button.tsx (45), Button.test.tsx (30) → 2 files, 75 lines, coherence 0.9
→ Proceed directly on current branch
```
