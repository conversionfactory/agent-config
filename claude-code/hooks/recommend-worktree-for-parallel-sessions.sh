#!/bin/bash
# When creating a new branch, checks if another Claude Code session is already
# running in the same git repo. If so, recommends using a git worktree instead.
#
# Two Claude Code sessions on the same repo means they share the working tree —
# file edits from one session can conflict with the other mid-task.
# Worktrees give each session its own isolated working directory on its own branch.

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Only check branch creation commands
echo "$CMD" | grep -qE '^\s*git\s+(checkout\s+-b|switch\s+-c)\b' || exit 0

# Must be in a git repo
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0

# Find other Claude Code processes (electron app or CLI)
OTHER_CLAUDE_PIDS=$(pgrep -if "claude" 2>/dev/null | grep -v "^$PPID$" | grep -v "^$$") || true

if [ -z "$OTHER_CLAUDE_PIDS" ]; then
  exit 0
fi

# Check if any of those processes are working inside the same git repo
FOUND_CONFLICT=false
for PID in $OTHER_CLAUDE_PIDS; do
  PROC_CWD=$(lsof -p "$PID" -d cwd -Fn 2>/dev/null | grep '^n' | sed 's/^n//' | head -1)
  if [ -n "$PROC_CWD" ] && [[ "$PROC_CWD" == "$GIT_ROOT"* ]]; then
    FOUND_CONFLICT=true
    break
  fi
done

if [ "$FOUND_CONFLICT" = false ]; then
  exit 0
fi

# Extract the branch name from the command so we can show the worktree equivalent
BRANCH=$(echo "$CMD" | grep -oE '\S+$')

echo "⚠️  Another Claude Code session is already running in this repo." >&2
echo "" >&2
echo "Instead of a branch, consider using a git worktree — each session gets" >&2
echo "its own isolated working directory so they can't step on each other." >&2
echo "" >&2
echo "  # Add a worktree for this work:" >&2
echo "  git worktree add ../$(basename "$GIT_ROOT")-${BRANCH} ${BRANCH}" >&2
echo "" >&2
echo "  # Then open the other Claude Code session in that directory." >&2
echo "" >&2
echo "Portless auto-assigns unique subdomains per worktree, so dev servers" >&2
echo "won't conflict either." >&2
echo "" >&2
echo "To proceed with a branch anyway, re-run the command." >&2
exit 2
