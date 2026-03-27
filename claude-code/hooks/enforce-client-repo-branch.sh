#!/bin/bash
# In client repos, blocks git commits and branch creation unless on a cf/* branch.
# Detects client repos by checking that the remote URL does not contain "conversionfactory".
# CF work in client repos must stay on cf/* branches (e.g. cf/development, cf/feature/123-name).

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Only check git commit and git checkout -b / git switch -c commands
echo "$CMD" | grep -qE '^\s*git\s+(commit|checkout\s+-b|switch\s+-c)\b' || exit 0

# Check if we're in a git repo
git rev-parse --git-dir > /dev/null 2>&1 || exit 0

# Check if this is a CF repo (remote URL contains conversionfactory)
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
if echo "$REMOTE_URL" | grep -qi "conversionfactory"; then
  exit 0  # CF repo — normal workflow applies
fi

# It's a client repo. Enforce cf/* branch naming.
BRANCH=$(git branch --show-current 2>/dev/null)

if ! echo "$BRANCH" | grep -qE '^cf/'; then
  echo "BLOCKED: In a client repo, all work must be on a cf/* branch." >&2
  echo "Current branch: $BRANCH" >&2
  echo "" >&2
  echo "Start from the CF development branch:" >&2
  echo "  git checkout cf/development" >&2
  echo "  git checkout -b cf/feature/123-description" >&2
  exit 2
fi
