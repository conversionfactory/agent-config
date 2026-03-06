# Agent Config

Global configuration for Claude Code and AI coding agents.

## Structure

```
claude/                  # ~/.claude/ config
├── CLAUDE.md            # Global instructions
├── settings.json        # Permissions, hooks, plugins
├── skills/              # Claude Code skills (~/.claude/skills/)
├── commands/            # Slash commands (~/.claude/commands/)
├── hooks/               # Hook scripts (~/.claude/hooks/)
└── agents-config/       # Agent definitions (~/.claude/agents/)

agents/                  # ~/.agents/ config
└── skills/              # Skills installed via npx skills add
```

## Setup

Symlink or copy to your home directory:

```bash
# Claude Code config
cp claude/CLAUDE.md ~/.claude/CLAUDE.md
cp claude/settings.json ~/.claude/settings.json
cp -r claude/skills/* ~/.claude/skills/
cp -r claude/commands/* ~/.claude/commands/
cp -r claude/hooks/* ~/.claude/hooks/
cp -r claude/agents-config/* ~/.claude/agents/

# Agent skills
cp -r agents/skills/* ~/.agents/skills/
```
