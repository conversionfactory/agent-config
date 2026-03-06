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
echo "║   Conversion Factory - Sync Config       ║"
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
