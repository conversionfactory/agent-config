#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.agent-config-backup/$(date +%Y%m%d-%H%M%S)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }
info() { echo -e "${BLUE}→${NC} $1"; }
err()  { echo -e "${RED}✗${NC} $1"; }

backup_if_exists() {
  local target="$1"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mkdir -p "$BACKUP_DIR"
    local backup_path="$BACKUP_DIR/$(basename "$target")"
    cp -r "$target" "$backup_path"
    warn "Backed up $(basename "$target") → $BACKUP_DIR/"
  fi
}

symlink_dir() {
  local src="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -d "$dest" ]; then
    backup_if_exists "$dest"
    rm -r "$dest"
  fi
  ln -s "$src" "$dest"
}

copy_file() {
  local src="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  backup_if_exists "$dest"
  cp "$src" "$dest"
}

copy_dir_contents() {
  local src="$1"
  local dest="$2"
  mkdir -p "$dest"
  for item in "$src"/*; do
    [ -e "$item" ] || continue
    local name
    name=$(basename "$item")
    if [ -d "$item" ]; then
      if [ -L "$dest/$name" ]; then
        rm "$dest/$name"
      fi
      cp -r "$item" "$dest/$name"
    else
      cp "$item" "$dest/$name"
    fi
  done
}

# ─── Detect tools ─────────────────────────────────────────────

detect_tools() {
  TOOLS=()
  if command -v claude >/dev/null 2>&1 || [ -d "$HOME/.claude" ]; then
    TOOLS+=("claude-code")
  fi
  if command -v codex >/dev/null 2>&1 || [ -d "$HOME/.codex" ]; then
    TOOLS+=("codex")
  fi
  if [ -d "/Applications/Cursor.app" ] || [ -d "$HOME/.cursor" ]; then
    TOOLS+=("cursor")
  fi
}

# ─── Install functions ─────────────────────────────────────────

install_claude_code() {
  info "Installing Claude Code config..."

  local claude_dir="$HOME/.claude"
  mkdir -p "$claude_dir"

  # CLAUDE.md
  copy_file "$SCRIPT_DIR/claude-code/CLAUDE.md" "$claude_dir/CLAUDE.md"
  log "CLAUDE.md"

  # settings.json
  copy_file "$SCRIPT_DIR/claude-code/settings.json" "$claude_dir/settings.json"
  log "settings.json"

  # Skills (symlink entire directory for easy sync)
  symlink_dir "$SCRIPT_DIR/shared/skills" "$claude_dir/skills"
  log "skills/ (symlinked)"

  # Commands
  copy_dir_contents "$SCRIPT_DIR/claude-code/commands" "$claude_dir/commands"
  log "commands/"

  # Agents
  copy_dir_contents "$SCRIPT_DIR/claude-code/agents" "$claude_dir/agents"
  log "agents/"

  # Hooks
  copy_dir_contents "$SCRIPT_DIR/claude-code/hooks" "$claude_dir/hooks"
  chmod +x "$claude_dir/hooks/"*.sh 2>/dev/null || true
  log "hooks/"

  echo ""
  log "Claude Code configured!"
}

install_codex() {
  info "Installing Codex CLI config..."

  local codex_dir="$HOME/.codex"
  mkdir -p "$codex_dir"

  copy_file "$SCRIPT_DIR/codex/AGENTS.md" "$codex_dir/AGENTS.md"
  log "AGENTS.md"

  echo ""
  log "Codex CLI configured!"
}

install_cursor() {
  info "Installing Cursor config..."

  local cursor_dir="$HOME/.cursor"
  mkdir -p "$cursor_dir/rules"

  copy_file "$SCRIPT_DIR/cursor/rules/team-conventions.md" "$cursor_dir/rules/team-conventions.md"
  log "rules/team-conventions.md"

  echo ""
  log "Cursor configured!"
}

# ─── Main ─────────────────────────────────────────────────────

main() {
  echo ""
  echo "╔══════════════════════════════════════════╗"
  echo "║   Conversion Factory - Agent Config      ║"
  echo "╚══════════════════════════════════════════╝"
  echo ""

  local install_all=false
  local selected_tools=()

  # Parse args
  while [[ $# -gt 0 ]]; do
    case $1 in
      --all) install_all=true; shift ;;
      --claude-code) selected_tools+=("claude-code"); shift ;;
      --codex) selected_tools+=("codex"); shift ;;
      --cursor) selected_tools+=("cursor"); shift ;;
      -h|--help)
        echo "Usage: ./install.sh [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --all          Install for all detected tools"
        echo "  --claude-code  Install Claude Code config only"
        echo "  --codex        Install Codex CLI config only"
        echo "  --cursor       Install Cursor config only"
        echo "  -h, --help     Show this help"
        echo ""
        echo "With no options, runs interactively."
        exit 0
        ;;
      *) err "Unknown option: $1"; exit 1 ;;
    esac
  done

  detect_tools

  if [ ${#TOOLS[@]} -eq 0 ]; then
    warn "No supported tools detected (Claude Code, Codex, Cursor)."
    warn "Install at least one, or use --claude-code, --codex, --cursor flags."
    exit 1
  fi

  # If specific tools requested via flags, use those
  if [ ${#selected_tools[@]} -gt 0 ]; then
    TOOLS=("${selected_tools[@]}")
  elif [ "$install_all" = true ]; then
    : # use detected tools as-is
  else
    # Interactive mode
    info "Detected tools: ${TOOLS[*]}"
    echo ""
    echo "Which tools do you want to configure?"
    echo ""

    local choices=()
    for i in "${!TOOLS[@]}"; do
      echo "  $((i+1)). ${TOOLS[$i]}"
    done
    echo "  A. All detected tools"
    echo ""
    read -rp "Enter choices (e.g. 1 2, or A for all): " choice_input

    if [[ "$choice_input" =~ [Aa] ]]; then
      choices=("${TOOLS[@]}")
    else
      for num in $choice_input; do
        local idx=$((num-1))
        if [ $idx -ge 0 ] && [ $idx -lt ${#TOOLS[@]} ]; then
          choices+=("${TOOLS[$idx]}")
        fi
      done
    fi

    if [ ${#choices[@]} -eq 0 ]; then
      err "No tools selected."
      exit 1
    fi

    TOOLS=("${choices[@]}")
  fi

  echo ""

  # Save selection for sync.sh
  mkdir -p "$HOME/.agent-config"
  printf '%s\n' "${TOOLS[@]}" > "$HOME/.agent-config/installed-tools"
  echo "$SCRIPT_DIR" > "$HOME/.agent-config/repo-path"

  # Install each tool
  for tool in "${TOOLS[@]}"; do
    case $tool in
      claude-code) install_claude_code ;;
      codex) install_codex ;;
      cursor) install_cursor ;;
    esac
  done

  # Summary
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  log "Setup complete! Configured: ${TOOLS[*]}"
  echo ""
  if [ -d "$BACKUP_DIR" ]; then
    warn "Backups saved to: $BACKUP_DIR"
    echo ""
  fi
  info "Run ./sync.sh anytime to pull updates and re-apply."
  echo ""
}

main "$@"
