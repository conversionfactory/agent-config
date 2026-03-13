#!/bin/bash
# Blocks `gh pr merge` unless all CI/deployment checks have passed.
# Works with Vercel, Heroku, GitHub Actions, or any status check.

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Only check gh pr merge commands
echo "$CMD" | grep -qE '^\s*gh\s+pr\s+merge\b' || exit 0

# Extract PR number from command, or use current branch
PR_NUM=$(echo "$CMD" | grep -oE '[0-9]+' | head -1)
if [ -z "$PR_NUM" ]; then
  PR_NUM=$(gh pr view --json number -q '.number' 2>/dev/null)
fi

if [ -z "$PR_NUM" ]; then
  echo "BLOCKED: Could not determine PR number to check." >&2
  exit 2
fi

# Check if all checks have passed
CHECK_STATUS=$(gh pr checks "$PR_NUM" 2>&1)
CHECK_EXIT=$?

if echo "$CHECK_STATUS" | grep -qiE 'fail|error'; then
  echo "BLOCKED: PR #$PR_NUM has failing checks. Fix the build before merging." >&2
  echo "" >&2
  echo "$CHECK_STATUS" | grep -iE 'fail|error' >&2
  exit 2
fi

if echo "$CHECK_STATUS" | grep -qiE 'pending|running|queued'; then
  echo "BLOCKED: PR #$PR_NUM has checks still running. Wait for them to complete." >&2
  echo "" >&2
  echo "$CHECK_STATUS" | grep -iE 'pending|running|queued' >&2
  exit 2
fi

if [ $CHECK_EXIT -ne 0 ]; then
  # No checks configured — let it through with a warning
  echo "WARNING: Could not verify checks for PR #$PR_NUM. Proceeding anyway." >&2
fi
