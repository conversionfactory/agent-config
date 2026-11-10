#!/bin/bash
# Blocks `gh pr merge` unless all CI/deployment checks have passed.
# Works with Vercel, Heroku, GitHub Actions, or any status check.

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Only check gh pr merge commands
# Match `gh pr merge` anywhere in the command, not just at the start of a line.
# The old anchor (^\s*gh) meant `cd /somewhere && gh pr merge 14` slipped past
# the guardrail entirely — a silent bypass, not just a bad error message.
echo "$CMD" | grep -qE '(^|[;&|]|\s)gh[[:space:]]+pr[[:space:]]+merge\b' || exit 0

# Look the PR up in its own repo: the session's working directory is often a
# different checkout (a `cd` prefix, -R, or parallel agents in one session).
# The shared parser only reads arguments after the merge command, so digits in
# a `cd /tmp/claude-501/...` prefix are never taken for a PR number.
source "$(dirname "$0")/lib/merge-target.sh"
resolve_merge_target "$INPUT"
PR_NUM=$MERGE_PR

if [ -z "$PR_NUM" ]; then
  echo "BLOCKED: Could not determine PR number to check." >&2
  echo "Pass the number, and -R owner/repo if you're not in that repo." >&2
  exit 2
fi

CHECK_STATUS=$(gh pr checks "$PR_NUM" -R "$MERGE_REPO" 2>&1)
CHECK_EXIT=$?

# gh exits non-zero both when checks fail AND when no checks exist at all.
# Distinguish them, so a repo with no CI isn't permanently blocked — and so a
# gh transport error ("failed to run git: ...") isn't mistaken for a failing
# check just because the word "failed" appears in it.
if echo "$CHECK_STATUS" | grep -qiE 'no checks reported|no commit found'; then
  echo "NOTE: No checks configured for PR #$PR_NUM. Proceeding." >&2
  exit 0
fi

# A real check listing has tab-separated rows containing a status word.
# If we can't see one, gh itself errored — say so instead of guessing.
if ! echo "$CHECK_STATUS" | grep -qiE 'pass|fail|pending|skipping|successful'; then
  echo "WARNING: Could not read checks for PR #$PR_NUM. Proceeding anyway." >&2
  echo "$CHECK_STATUS" | head -3 >&2
  exit 0
fi

if echo "$CHECK_STATUS" | grep -qiE '^[^\t]*\t?(fail|error)'; then
  echo "BLOCKED: PR #$PR_NUM has failing checks. Fix the build before merging." >&2
  echo "" >&2
  echo "$CHECK_STATUS" | grep -iE 'fail|error' >&2
  exit 2
fi

if echo "$CHECK_STATUS" | grep -qiE 'pending|in_progress|queued'; then
  echo "BLOCKED: PR #$PR_NUM has checks still running. Wait for them to complete." >&2
  echo "" >&2
  echo "$CHECK_STATUS" | grep -iE 'pending|in_progress|queued' >&2
  exit 2
fi

exit 0
