#!/bin/bash
# Shared by the merge hooks and /review: work out which repo and PR a
# `gh pr merge` command is about, and where its review marker lives.
#
# The session's working directory is often a different repo from the one being
# merged (`cd ~/code/other && gh pr merge 12`, `gh pr merge 12 -R owner/repo`,
# parallel agents in one session), so never key anything on it alone.

# Lowercase owner/repo from a git remote URL (ssh or https).
repo_slug_from_url() {
  echo "$1" | sed -E 's#^(git@|ssh://git@|https?://)([^/:]+)[:/]##; s#\.git$##; s#/$##' | tr 'A-Z' 'a-z'
}

# owner/repo for a local checkout, from its origin remote.
repo_slug_for_dir() {
  local url
  url=$(git -C "${1:-.}" remote get-url origin 2>/dev/null) || return 1
  repo_slug_from_url "$url"
}

# Marker path for a repo + branch. One marker per repo, so reviewing
# `development` in one repo never unlocks `development` in another.
review_marker_path() {
  echo "$HOME/.claude/.review-passed-$(echo "$1" | tr '/' '-')--$(echo "$2" | tr '/' '-')"
}

# Sets MERGE_DIR, MERGE_REPO, MERGE_PR, MERGE_HEAD for a hook's JSON input.
# MERGE_PR/MERGE_HEAD stay empty when the PR can't be looked up.
resolve_merge_target() {
  local input="$1" cmd before args sel cd_arg
  cmd=$(echo "$input" | jq -r '.tool_input.command // ""')
  MERGE_DIR=$(echo "$input" | jq -r '.cwd // empty')
  [ -n "$MERGE_DIR" ] || MERGE_DIR=$PWD

  # The last `cd X` before the merge is where gh actually runs.
  before=$(echo "$cmd" | sed -E 's/gh[[:space:]]+pr[[:space:]]+merge.*//')
  cd_arg=$(echo "$before" | grep -oE '(^|[;&|[:space:]])cd[[:space:]]+("[^"]+"|'"'"'[^'"'"']+'"'"'|[^[:space:];&|]+)' \
    | tail -1 | sed -E 's/^[;&|[:space:]]*cd[[:space:]]+//; s/^["'"'"']//; s/["'"'"']$//')
  if [ -n "$cd_arg" ]; then
    cd_arg="${cd_arg/#\~/$HOME}"
    case "$cd_arg" in
      /*) MERGE_DIR=$cd_arg ;;
      *) MERGE_DIR="$MERGE_DIR/$cd_arg" ;;
    esac
  fi

  # -R/--repo wins over the directory's remote, as it does for gh.
  args=$(echo "$cmd" | sed -E 's/.*gh[[:space:]]+pr[[:space:]]+merge//')
  MERGE_REPO=$(echo "$args" | grep -oE '(-R|--repo)[[:space:]=]+[^[:space:];&|]+' | head -1 \
    | sed -E 's/^(-R|--repo)[[:space:]=]+//')
  if [ -n "$MERGE_REPO" ]; then
    MERGE_REPO=$(repo_slug_from_url "$MERGE_REPO")
  else
    MERGE_REPO=$(repo_slug_for_dir "$MERGE_DIR")
  fi

  # The PR: a number, URL, or branch argument; none means the checkout's branch.
  sel=$(echo "$args" | sed -E 's/(-R|--repo)[[:space:]=]+[^[:space:]]+//; s/[;&|].*//' | tr ' ' '\n' \
    | grep -vE '^-|^$' | head -1)
  MERGE_PR=""
  MERGE_HEAD=""
  local info
  if [ -n "$MERGE_REPO" ]; then
    info=$(cd "$MERGE_DIR" 2>/dev/null && gh pr view $sel -R "$MERGE_REPO" --json number,headRefName \
      -q '"\(.number) \(.headRefName)"' 2>/dev/null)
  fi
  if [ -n "$info" ]; then
    MERGE_PR=${info%% *}
    MERGE_HEAD=${info#* }
  fi
}
