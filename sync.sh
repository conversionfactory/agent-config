#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }
info() { echo -e "${BLUE}→${NC} $1"; }
err()  { echo -e "${RED}✗${NC} $1"; }

CONFIG_DIR="$HOME/.agent-config"
TOOLS_FILE="$CONFIG_DIR/installed-tools"
REPO_PATH_FILE="$CONFIG_DIR/repo-path"

# Determine repo path
if [ -f "$REPO_PATH_FILE" ]; then
  REPO_DIR="$(cat "$REPO_PATH_FILE")"
else
  REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

if [ ! -d "$REPO_DIR/.git" ]; then
  err "Not a git repo: $REPO_DIR"
  exit 1
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║         Agent Config - Sync              ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Pull latest
info "Pulling latest changes..."
cd "$REPO_DIR"

BEFORE=$(git rev-parse HEAD)
git pull --ff-only origin main 2>/dev/null || git pull --ff-only 2>/dev/null || {
  warn "Could not fast-forward. You may have local changes."
  warn "Run 'git pull' manually in $REPO_DIR"
}
AFTER=$(git rev-parse HEAD)

if [ "$BEFORE" = "$AFTER" ]; then
  log "Already up to date."
else
  info "Updated: $(git log --oneline "$BEFORE".."$AFTER" | wc -l | tr -d ' ') new commits"
  echo ""
  git log --oneline "$BEFORE".."$AFTER"
  echo ""
fi

# Re-run install
if [ ! -f "$TOOLS_FILE" ]; then
  warn "No previous install found. Running install.sh..."
  exec "$REPO_DIR/install.sh"
fi

TOOLS=()
while IFS= read -r line; do
  TOOLS+=("$line")
done < "$TOOLS_FILE"

info "Re-applying config for: ${TOOLS[*]}"
echo ""

# Build flags
FLAGS=()
for tool in "${TOOLS[@]}"; do
  FLAGS+=("--$tool")
done

"$REPO_DIR/install.sh" "${FLAGS[@]}"

# Mirror skills into the second-brain vault repo
#
# Claude Code cloud sessions run against a single repo, so a session on the
# vault needs its own copy of the skills that operate on it. Skip silently
# when SECOND_BRAIN_VAULT is unset — not everyone keeps a vault.
VAULT_SKILLS=(second-brain)

if [ -n "${SECOND_BRAIN_VAULT:-}" ] && [ -d "$SECOND_BRAIN_VAULT/.git" ]; then
  echo ""
  info "Mirroring skills into vault: $SECOND_BRAIN_VAULT"

  for skill in "${VAULT_SKILLS[@]}"; do
    src="$REPO_DIR/shared/skills/$skill"
    if [ ! -d "$src" ]; then
      warn "  $skill — not found in shared/skills, skipping"
      continue
    fi

    mkdir -p "$SECOND_BRAIN_VAULT/.agents/skills" "$SECOND_BRAIN_VAULT/.claude/skills"
    rsync -a --delete "$src/" "$SECOND_BRAIN_VAULT/.agents/skills/$skill/"
    ln -sfn "../../.agents/skills/$skill" "$SECOND_BRAIN_VAULT/.claude/skills/$skill"
    log "  $skill"
  done

  if git -C "$SECOND_BRAIN_VAULT" status --porcelain -- .agents/skills .claude/skills | grep -q .; then
    warn "Vault skills changed — commit and push in $SECOND_BRAIN_VAULT"
  fi
elif [ -n "${SECOND_BRAIN_VAULT:-}" ]; then
  warn "SECOND_BRAIN_VAULT set but not a git repo — skipping vault skill mirror"
fi
