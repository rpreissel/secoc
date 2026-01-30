---
name: commit-size-guard
description: Warns when a commit is too large or contains unrelated changes
trigger: before_commit
auto_run: true
---

# Commit Size Guard

Execute BEFORE creating git commits.

## Config
Read from `.opencode/config.json` → `skills.commit-size-guard` (defaults shown):
- `max-files`: 15
- `max-lines`: 500
- `max-file-lines`: 300
- `similarity-threshold`: 0.3
- `auto-split`: true
- `warning-only`: true

## Workflow

**1. Analyze staged changes**
- Run `git diff --cached --numstat`
- Count files, lines changed
- Identify directories and file types

**2. Check thresholds**
- Files > max-files → Warn
- Lines > max-lines → Warn
- Single file > max-file-lines → Warn

**3. Calculate coherence (0.0 - 1.0)**
- Same directory: +0.4
- Same file type: +0.2
- Related names (e.g., `user.ts` + `user.test.ts`): +0.3
- Score < threshold → Warn

**4. If warnings:**
- Display summary with stats and detected groups
- Ask user (use `question` tool):
  - Option 1: Split into {N} commits (Recommended)
  - Option 2: Commit as is
  - Option 3: Manual review
- If split: Create separate commits per group
- Otherwise: Proceed with commit

**5. If no warnings:**
- Proceed directly with commit

## Example
User commits 25 files: Auth (8), UI (12), Tests (5)
→ Warn: "Large commit: 25 files (limit: 15)"
→ Suggest: Split into 3 commits
→ Create focused commits per group
