#!/bin/bash
# Prints the code /review should look at.
#   review-context.sh                  current branch's PR diff, else branch vs base + uncommitted
#   review-context.sh 92 [-R o/r]      PR diff (also "#92" or a PR URL)
#   review-context.sh path/to/file     the file
#   review-context.sh <git-ref>        diff of ref...HEAD
args="$*"
repo=$(echo "$args" | grep -oE '(-R|--repo)[[:space:]=]+[^[:space:]]+' | head -1 | sed -E 's/^(-R|--repo)[[:space:]=]+//')
[ -z "$repo" ] && repo=$(echo "$args" | grep -oE '(^|[[:space:](])[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+' | grep -v '/pull' | grep -vE '^[[:space:](]*(origin|feature|fix|hotfix|cf)/' | head -1 | sed -E 's/^[[:space:](]+//')
repo_flag=()
[ -n "$repo" ] && repo_flag=(-R "$repo")
rest=$(echo "$args" | sed -E 's/(-R|--repo)[[:space:]=]+[^[:space:]]+//')

pr=$(echo "$rest" | grep -oE '/pull/[0-9]+' | head -1 | grep -oE '[0-9]+')
[ -z "$pr" ] && pr=$(echo "$rest" | grep -oE '(^|[[:space:]#])#?[0-9]+([[:space:]]|$)' | head -1 | grep -oE '[0-9]+')
if [ -z "$repo" ] && echo "$rest" | grep -qE 'github\.com/[^/]+/[^/]+/pull/'; then
  repo=$(echo "$rest" | grep -oE 'github\.com/[^/]+/[^/]+' | head -1 | sed 's#github.com/##')
  repo_flag=(-R "$repo")
fi

if [ -n "$pr" ]; then
  echo "# PR #$pr ${repo:+in $repo}"
  gh pr view "$pr" "${repo_flag[@]}" --json title,headRefName,baseRefName -q '"# " + .title + " (" + .headRefName + " -> " + .baseRefName + ")"'
  gh pr diff "$pr" "${repo_flag[@]}" || echo "Could not load PR #$pr diff."
  exit 0
fi

target=$(echo "$rest" | xargs)
if [ -n "$target" ] && [ -f "$target" ]; then
  cat "$target"
  exit 0
fi
if [ -n "$target" ]; then
  if git rev-parse --verify --quiet "$target" >/dev/null; then
    git diff "$target"...HEAD
  else
    echo "Not a file, PR, or git ref: $target"
  fi
  exit 0
fi

branch=$(git branch --show-current 2>/dev/null)
if [ -z "$branch" ]; then
  echo "Not in a git repo. Pass a PR number (with -R owner/repo), file, or git ref."
  exit 0
fi
if gh pr view --json number >/dev/null 2>&1; then
  echo "# PR for $branch"
  gh pr diff
else
  base=""
  for b in origin/development origin/cf/development origin/main origin/master; do
    git rev-parse --verify --quiet "$b" >/dev/null && { base=$b; break; }
  done
  echo "# $branch vs ${base:-HEAD} (no PR yet), plus uncommitted changes"
  [ -n "$base" ] && git diff "$base"...HEAD
  git diff HEAD
fi
