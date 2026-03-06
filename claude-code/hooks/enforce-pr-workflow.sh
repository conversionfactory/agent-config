#!/bin/bash
# Blocks `git merge` when on main or development branches.
# Forces the PR workflow — no direct merges into protected branches.

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Only check git merge commands
echo "$CMD" | grep -qE '^\s*git\s+merge\b' || exit 0

# Check current branch
BRANCH=$(git branch --show-current 2>/dev/null)

if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "development" ]; then
  echo "BLOCKED: Direct merges into '$BRANCH' are not allowed." >&2
  echo "Open a PR instead: gh pr create --base $BRANCH" >&2
  exit 2
fi
