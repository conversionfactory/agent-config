#!/bin/bash
# Intercepts `gh repo fork` and asks the user to confirm they actually want to fork.
# The common mistake: forking a client repo instead of being added as a collaborator
# and creating a cf/development branch. Forks create a copy under your account,
# which means the client can't see the work until it's manually copied back.

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Only check gh repo fork commands
echo "$CMD" | grep -qE '^\s*gh\s+repo\s+fork\b' || exit 0

echo "⚠️  WAIT: You're about to fork a repo." >&2
echo "" >&2
echo "Did you mean to get added as a collaborator instead?" >&2
echo "" >&2
echo "Forking creates a copy under your account — the client won't see your work" >&2
echo "until someone manually copies it back. This is usually not what you want." >&2
echo "" >&2
echo "The CF workflow for client repos:" >&2
echo "  1. Ask the client to add you as a collaborator on their repo" >&2
echo "  2. Clone their repo directly: git clone <their-repo-url>" >&2
echo "  3. Create a CF branch: git checkout -b cf/development" >&2
echo "  4. Work on cf/* branches, PR into cf/development, deliver via one PR to their main" >&2
echo "" >&2
echo "If you truly need a fork (e.g. open source contribution), re-run the command." >&2
echo "BLOCKED: Confirm this is intentional before proceeding." >&2
exit 2
