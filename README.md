# Agent Config

Shared AI coding tool configuration for the Conversion Factory team. One repo to configure Claude Code, Codex CLI, and Cursor with our team's skills, commands, agents, and conventions.

## Setup (First Time)

Clone the repo and run the install script:

```bash
cd ~/Documents/code
git clone git@github.com:conversionfactory/agent-config.git
cd agent-config
./install.sh --all
```

This will:
1. Back up any existing config (`~/.claude/`, `~/.codex/`, `~/.cursor/`) to `~/.agent-config-backup/`
2. Copy `claude-code/CLAUDE.md` → `~/.claude/CLAUDE.md`
3. Copy `claude-code/settings.json` → `~/.claude/settings.json`
4. Symlink `shared/skills/` → `~/.claude/skills/` (so syncing just works)
5. Copy `claude-code/commands/*` → `~/.claude/commands/`
6. Copy `claude-code/agents/*` → `~/.claude/agents/`
7. Copy `claude-code/hooks/*` → `~/.claude/hooks/`
8. Copy `codex/AGENTS.md` → `~/.codex/AGENTS.md`
9. Copy `cursor/rules/team-conventions.md` → `~/.cursor/rules/team-conventions.md`

After install, set your personal preferences (model, etc.) via Claude Code's `/settings` command. The team config intentionally omits personal preferences.

## Update (Already Installed)

Pull the latest config and re-apply:

```bash
cd ~/Documents/code/agent-config
./sync.sh
```

This runs `git pull` then re-runs `./install.sh` for your previously selected tools. Your existing config is backed up before overwriting.

If `sync.sh` isn't available (older install), just pull and re-run:

```bash
cd ~/Documents/code/agent-config
git pull
./install.sh --all
```

## What Gets Installed

### Skills (50+)

Shared skills installed to `~/.claude/skills/` (symlinked from `shared/skills/`):

- **Marketing**: copywriting, page-cro, pricing-strategy, email-sequence, ad-creative, content-strategy, paid-ads, seo-audit, and more
- **Engineering**: nextjs, rails, prisma, drizzle, stripe, deployment, systematic-debugging, test-driven-development, and more
- **Design**: canvas-design, shadcn-ui, web-design-guidelines, brand-guidelines, theme-factory, and more

### Slash Commands

Installed to `~/.claude/commands/`:

| Command | Description |
|---------|-------------|
| `/start` | Pick or create a GitHub issue and start a branch |
| `/workflow` | Show the 5-step development workflow with current status |
| `/commit` | Create a well-crafted git commit |
| `/pr` | Create a pull request with summary |
| `/review` | Code review (required before merging PRs) |
| `/test` | Generate tests |
| `/explain` | Explain code with diagrams |
| `/refactor` | Refactor with focus area |
| `/debug` | Debug an issue systematically |

### Agents

Installed to `~/.claude/agents/`:

| Agent | Purpose |
|-------|---------|
| architect | System design decisions |
| code-reviewer | Code review |
| debugger | Debugging specialist |
| security-scanner | Security review |
| test-writer | Test generation |

### Hooks

Installed to `~/.claude/hooks/`:

| Hook | Trigger | What it does |
|------|---------|-------------|
| Command history | PreToolUse (Bash) | Logs all commands to `~/.claude/command-history.log` |
| rm -rf blocker | PreToolUse (Bash) | Blocks `rm -rf`, requires `trash` instead |
| PR workflow enforcer | PreToolUse (Bash) | Blocks `git merge` on main/development — must open a PR |
| Review enforcer | PreToolUse (Bash) | Blocks `gh pr merge` until `/review` has been run |
| Prettier auto-format | PostToolUse (Write/Edit) | Auto-formats .ts/.tsx/.js/.jsx files on save |
| Plan review | PostToolUse (ExitPlanMode) | Gets Codex second opinion on plans |

### Git Workflow (Enforced)

The config enforces this branching strategy via hooks:

```
main (production)
  └── development (primary working branch)
        ├── feature/42-add-user-auth
        └── fix/63-login-redirect
```

- **No direct merges** into `main` or `development` — always open a PR
- **No merging PRs** without running `/review` first
- Branch naming: `feature/123-name`, `fix/123-name`, `hotfix/123-name`

### Development Workflow

Every piece of work follows 5 steps:

| Step | Action | Command |
|------|--------|---------|
| 1 | Pick or create an issue | `/start` |
| 2 | Plan the approach | Enter plan mode |
| 3 | Implement | Code + `/commit` |
| 4 | Review | `/review` |
| 5 | Ship | `/pr` → `development` |

Run `/workflow` to see these steps with your current branch status.

### GitHub Issues

Use GitHub Issues to coordinate work and avoid merge conflicts. Before starting work, check open issues or create a new one. Self-assign issues you're working on. Branch names include issue numbers (`feature/123-description`). Link PRs to issues with "closes #123" in the description.

## Repo Structure

```
agent-config/
├── install.sh                   # One-command setup
├── sync.sh                      # Pull latest + re-apply
│
├── shared/                      # Shared across all tools
│   └── skills/                  # All skills (canonical source)
│
├── claude-code/                 # Claude Code specific
│   ├── CLAUDE.md                # Global instructions
│   ├── settings.json            # Team permissions, hooks, plugins
│   ├── commands/                # Slash commands
│   ├── agents/                  # Agent definitions
│   └── hooks/                   # Hook scripts
│
├── codex/                       # Codex CLI specific
│   └── AGENTS.md                # Team conventions for Codex
│
├── cursor/                      # Cursor specific
│   └── rules/
│       └── team-conventions.md  # Team conventions for Cursor
│
└── github/                      # GitHub templates (opt-in)
    └── ISSUE_TEMPLATE/
        ├── feature.md           # Feature/enhancement template
        └── bug.md               # Bug report template
```

### Portless (Local Dev URLs)

The config recommends [portless](https://github.com/vercel-labs/portless) to eliminate port conflicts across the team. Instead of `localhost:3000`, each app gets a stable named URL like `myapp.localhost:1355`.

```bash
# Install once
npm install -g portless

# Use instead of bare dev commands
portless myapp next dev
portless myapi rails s
```

Git worktrees automatically get unique subdomains (`myapp-feature-branch.localhost:1355`), so team members can run multiple branches simultaneously with zero port conflicts.

See `CLAUDE.md` for full usage rules.

### GitHub Issue Templates (Optional)

The `github/ISSUE_TEMPLATE/` directory contains issue templates for feature requests and bug reports. To use them in a client project, copy the directory to the project's `.github/` folder:

```bash
cp -r ~/Documents/code/agent-config/github/ISSUE_TEMPLATE/ .github/ISSUE_TEMPLATE/
```

## Adding New Skills

1. Create a directory in `shared/skills/your-skill-name/`
2. Add a `SKILL.md` with the skill definition
3. Optionally add `references/` and `evals/` subdirectories
4. Commit, push, and tell the team to run `./sync.sh`

Skills in `shared/skills/` are automatically available to Claude Code via the symlink.

## Install Options

```bash
./install.sh              # Interactive — asks which tools to configure
./install.sh --all        # Configure all detected tools
./install.sh --claude-code  # Claude Code only
./install.sh --codex      # Codex CLI only
./install.sh --cursor     # Cursor only
```
