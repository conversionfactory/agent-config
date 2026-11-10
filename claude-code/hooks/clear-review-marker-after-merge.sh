#!/bin/bash
# PostToolUse: remove the /review marker once a `gh pr merge` has actually
# merged the PR, so the next PR from this branch needs a fresh review.

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')
# Mentions in heredoc bodies and quoted text don't count (lib/strip-command.py).
source "$(dirname "$0")/lib/merge-target.sh"
is_merge_command "$CMD" || exit 0

resolve_merge_target "$INPUT"
[ -n "$MERGE_PR" ] || exit 0

STATE=$(gh pr view "$MERGE_PR" -R "$MERGE_REPO" --json state -q .state 2>/dev/null)
[ "$STATE" = "MERGED" ] || exit 0

rm -f "$(review_marker_path "$MERGE_REPO" "$MERGE_HEAD")"
exit 0
