---
allowed-tools: Bash(git:*)
description: Create a well-crafted git commit
---

## Context

Current git status:
!`git status --short`

Staged changes:
!`git diff --cached --stat`

Unstaged changes:
!`git diff --stat`

Recent commits for style reference:
!`git log --oneline -5`

## Task

Based on the changes above:
1. If there are unstaged changes, ask if I want to stage them
2. Analyze the staged changes to understand what was done
3. Draft a concise, meaningful commit message following conventional commits format
4. Create the commit

Keep the message focused on the "why" not the "what".
