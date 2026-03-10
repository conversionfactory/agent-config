---
allowed-tools: Bash(git:*), Bash(gh:*)
description: Pick or create a GitHub issue and start a branch
---

## Context

Current branch:
!`git branch --show-current 2>/dev/null || echo "not a git repo"`

Open issues assigned to you:
!`gh issue list --assignee @me --state open --limit 10 2>/dev/null || echo "Could not fetch issues (gh not configured or no repo)"`

All open issues:
!`gh issue list --state open --limit 15 2>/dev/null || echo "Could not fetch issues (gh not configured or no repo)"`

## Task

Help me start a new piece of work by following these steps:

1. **Show the open issues** listed above
2. **Ask me to pick one** or create a new issue:
   - If picking an existing issue, note its number and title
   - If creating new, ask for a title and description, then run `gh issue create`
3. **Self-assign the issue**: `gh issue edit <number> --add-assignee @me`
4. **Create a branch** from `development`:
   ```bash
   git checkout development
   git pull origin development
   git checkout -b feature/<issue-number>-<short-description>
   # or fix/<issue-number>-<short-description> for bugs
   ```
5. **Tell me to enter plan mode** to design the implementation before coding

Use `feature/` prefix for enhancements and `fix/` prefix for bugs. Always include the issue number in the branch name.
