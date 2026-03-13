# Agent Config

Shared AI coding tool configuration for the Conversion Factory team. One repo to configure Claude Code, Codex CLI, and Cursor with our team's skills, commands, agents, and conventions.

## Setup (First Time)

Paste this into Claude Code:

> Clone the agent-config repo from git@github.com:conversionfactory/agent-config.git and run ./install.sh --all

Or run it manually:

```bash
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

Paste this into Claude Code:

> Pull the latest agent-config and run ./sync.sh to re-apply

Or run it manually from wherever you cloned agent-config:

```bash
cd <your-agent-config-directory>
./sync.sh
```

This runs `git pull` then re-runs `./install.sh` for your previously selected tools. Your existing config is backed up before overwriting.

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
| Checks enforcer | PreToolUse (Bash) | Blocks `gh pr merge` if CI/deployment checks are failing or running |
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
- **No merging PRs** with failing or pending CI/deployment checks
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
# Use instead of bare dev commands (no install needed)
npx portless myapp next dev
npx portless myapi rails s
```

Git worktrees automatically get unique subdomains (`myapp-feature-branch.localhost:1355`), so team members can run multiple branches simultaneously with zero port conflicts.

See `CLAUDE.md` for full usage rules.

### GitHub Issue Templates (Optional)

The `github/ISSUE_TEMPLATE/` directory contains issue templates for feature requests and bug reports. To use them in a client project, copy the directory to the project's `.github/` folder:

```bash
cp -r <your-agent-config-directory>/github/ISSUE_TEMPLATE/ .github/ISSUE_TEMPLATE/
```

## Adding New Skills

1. Create a directory in `shared/skills/your-skill-name/`
2. Add a `SKILL.md` with the skill definition
3. Optionally add `references/` and `evals/` subdirectories
4. Commit, push, and tell the team to run `./sync.sh`

Skills in `shared/skills/` are automatically available to Claude Code via the symlink.

## Recommended Plugins (Optional)

These Claude Code plugins aren't installed by `install.sh` — team members install them individually if useful for their work.

| Plugin | What it does | Install |
|--------|-------------|---------|
| [design-and-refine](https://github.com/0xdesign/design-plugin) | Iterative UI design — generates 5 variations, collects visual feedback, synthesizes a refined design with implementation plan | `/plugin install design-and-refine@design-plugins` |
| [agentation](https://www.agentation.com/) | Visual UI feedback — click elements in the browser, annotate bugs/feedback, get structured context (selectors, file paths, component hierarchy) for AI agents | `npm install agentation` |

**design-and-refine** is useful for frontend/design work (landing pages, components, UI exploration). It auto-detects your framework and styling system (Next.js + Tailwind + shadcn works great), renders variations at `/__design_lab`, and outputs a `DESIGN_PLAN.md`. Requires your dev server to be running.

**agentation** is useful for visual debugging and UI feedback. Click on any element in your browser, add notes, and it generates structured markdown with CSS selectors, source file paths, and React component trees that you can paste into Claude Code. Also supports an MCP server for real-time sync. Desktop only.

## Install Options

```bash
./install.sh              # Interactive — asks which tools to configure
./install.sh --all        # Configure all detected tools
./install.sh --claude-code  # Claude Code only
./install.sh --codex      # Codex CLI only
./install.sh --cursor     # Cursor only
```
