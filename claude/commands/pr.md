---
allowed-tools: Bash(git:*), Bash(gh:*)
argument-hint: [base-branch]
description: Create a pull request with proper summary
---

## Context

Current branch:
!`git branch --show-current`

Commits on this branch (vs $ARGUMENTS):
!`git log --oneline ${1:-main}..HEAD`

Files changed:
!`git diff --stat ${1:-main}..HEAD`

## Task

1. Analyze ALL commits on this branch (not just the latest)
2. Push the branch if needed
3. Create a PR with:
   - Clear, descriptive title
   - Summary section with bullet points
   - Test plan section
4. Return the PR URL
