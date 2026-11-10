#!/bin/bash
# Blocks `gh pr merge` unless /review has been run for the PR's own repo and
# head branch. /review writes the marker (see review-marker.sh).

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Only check gh pr merge commands
# Match `gh pr merge` anywhere in the command, not just at the start of a line.
# The old anchor (^\s*gh) meant `cd /somewhere && gh pr merge 14` slipped past
# the guardrail entirely — a silent bypass, not just a bad error message.
# Mentions don't count: heredoc bodies and quoted text are ignored unless they
# run as code (lib/strip-command.py).
source "$(dirname "$0")/lib/merge-target.sh"
is_merge_command "$CMD" || exit 0

# Key on the PR being merged, not the session's working directory: that is
# often another repo (a `cd` prefix, -R, or parallel agents in one session).
resolve_merge_target "$INPUT"

if [ -z "$MERGE_HEAD" ]; then
  echo "BLOCKED: Couldn't look up the PR being merged${MERGE_REPO:+ in $MERGE_REPO}." >&2
  echo "Pass the number, and -R owner/repo if you're not in that repo: gh pr merge <number> -R <owner/repo>" >&2
  exit 2
fi

MARKER=$(review_marker_path "$MERGE_REPO" "$MERGE_HEAD")
if [ ! -f "$MARKER" ]; then
  echo "BLOCKED: Run /review before merging a PR." >&2
  echo "No review recorded for $MERGE_REPO branch $MERGE_HEAD (PR #$MERGE_PR)." >&2
  echo "Run: /review $MERGE_PR -R $MERGE_REPO" >&2
  exit 2
fi

# Don't consume the marker here. Other PreToolUse hooks (e.g. the CI-checks
# hook) can still block this merge, and deleting now would force a re-review.
# clear-review-marker-after-merge.sh removes it once the merge succeeds.
exit 0
