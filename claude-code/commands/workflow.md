---
description: Show the 5-step development workflow with current status
---

## Context

Current branch:
!`git branch --show-current 2>/dev/null || echo "not a git repo"`

Branch status:
!`git status --short 2>/dev/null | head -10`

Review status:
!`branch=$(git branch --show-current 2>/dev/null); marker="$HOME/.claude/.review-passed-$(echo "$branch" | tr '/' '-')"; if [ -f "$marker" ]; then echo "✓ Review passed"; else echo "✗ Not yet reviewed"; fi`

Open PRs for this branch:
!`gh pr list --head "$(git branch --show-current 2>/dev/null)" --state open 2>/dev/null || echo "No open PRs (or gh not available)"`

## Development Workflow

Here's the 5-step process for every piece of work:

### Step 1: Pick or Create an Issue
- Run `/start` to browse open issues or create a new one
- Self-assign the issue so teammates know it's taken
- Creates a branch named `feature/123-description` or `fix/123-description`

### Step 2: Plan
- Enter plan mode to design the approach before writing code
- Think through the implementation, identify files to change, consider edge cases

### Step 3: Implement
- Write the code following team conventions
- Make focused commits as you go with `/commit`
- Run linting and tests before finishing

### Step 4: Review
- Run `/review` to review the code (required before merging)
- Fix any critical or warning issues found

### Step 5: Ship
- Run `/pr` to create a pull request → `development`
- Link the PR to the issue (closes #123)
- After merge, return to `development`: `git checkout development && git pull`

---

**Quick commands**: `/start` → plan mode → code → `/review` → `/pr`
