#!/bin/bash
# Prints or sets the review marker that unlocks `gh pr merge`.
#   review-marker.sh                       print the path for this checkout's branch
#   review-marker.sh --set                 mark this checkout's branch reviewed
#   review-marker.sh --set 92 [-R o/r]     mark PR #92's head branch reviewed
source "$(dirname "$0")/lib/merge-target.sh"

SET=""
[ "$1" = "--set" ] && { SET=1; shift; }
args="$*"
REPO=$(echo "$args" | grep -oE '(-R|--repo)[[:space:]=]+[^[:space:]]+' | head -1 | sed -E 's/^(-R|--repo)[[:space:]=]+//')
[ -z "$REPO" ] && REPO=$(echo "$args" | grep -oE '(^|[[:space:](])[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+' | grep -v '/pull' | grep -vE '^[[:space:](]*(origin|feature|fix|hotfix|cf)/' | head -1 | sed -E 's/^[[:space:](]+//')
PR=$(echo "$args" | grep -oE '/pull/[0-9]+' | head -1 | grep -oE '[0-9]+')
[ -z "$PR" ] && PR=$(echo "$args" | sed -E 's/(-R|--repo)[[:space:]=]+[^[:space:]]+//' | grep -oE '(^|[[:space:]#])#?[0-9]+([[:space:]]|$)' | head -1 | grep -oE '[0-9]+')
[ -z "$REPO" ] && echo "$args" | grep -qE 'github\.com/[^/]+/[^/]+/pull/' && REPO=$(echo "$args" | grep -oE 'github\.com/[^/]+/[^/]+' | head -1 | sed 's#github.com/##')

if [ -n "$PR" ]; then
  [ -n "$REPO" ] || REPO=$(repo_slug_for_dir .)
  REPO=$(repo_slug_from_url "$REPO")
  BRANCH=$(gh pr view "$PR" -R "$REPO" --json headRefName -q .headRefName 2>/dev/null)
else
  REPO=$(repo_slug_for_dir .)
  BRANCH=$(git branch --show-current 2>/dev/null)
fi
if [ -z "$REPO" ] || [ -z "$BRANCH" ]; then
  echo "Couldn't resolve a repo and branch (pass a PR number and -R owner/repo)." >&2
  exit 1
fi
MARKER=$(review_marker_path "$REPO" "$BRANCH")
if [ -n "$SET" ]; then
  touch "$MARKER"
  echo "Review marker set for $REPO $BRANCH"
else
  echo "$MARKER"
fi
