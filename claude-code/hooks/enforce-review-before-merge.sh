#!/bin/bash
# Blocks `gh pr merge` unless /review has been run for the current branch.
# The /review command writes a marker file that this hook checks for.

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Only check gh pr merge commands
echo "$CMD" | grep -qE '^\s*gh\s+pr\s+merge\b' || exit 0

# Check for review marker
BRANCH=$(git branch --show-current 2>/dev/null)
MARKER="$HOME/.claude/.review-passed-$(echo "$BRANCH" | tr '/' '-')"

if [ ! -f "$MARKER" ]; then
  echo "BLOCKED: Run /review before merging a PR." >&2
  echo "This ensures all code is reviewed before it lands." >&2
  exit 2
fi

# Clean up marker after successful check (it'll proceed to merge)
rm -f "$MARKER"
