# Agent Config

Shared AI coding tool configuration for your team. One repo to configure Claude Code, Codex CLI, and Cursor with your team's skills, commands, agents, and conventions.

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
5. Symlink `shared/tools/` → `~/.claude/tools/` when present (supporting docs and CLIs referenced by skills)
6. Copy `claude-code/commands/*` → `~/.claude/commands/`
7. Copy `claude-code/agents/*` → `~/.claude/agents/`
8. Copy `claude-code/hooks/*` → `~/.claude/hooks/`
9. Copy `codex/AGENTS.md` → `~/.codex/AGENTS.md`
10. Copy `cursor/rules/team-conventions.md` → `~/.cursor/rules/team-conventions.md`

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

### Skills

Shared skills installed to `~/.claude/skills/` (symlinked from `shared/skills/`):

- **CF team workflow** (the 14-stage client delivery process): `client-intake`, `customer-research`, `positioning`, `brand-strategy`, `sitemap-workshop`, `creative-direction`, `logo-design`, `brand-style-guide`, `website-copy`, `wireframes`, `website-build-native`, `website-build-webflow`, `website-build-framer`, `client-handoff`, `launch`, `growth-engine`. Plus `audit` (full product marketing audit orchestrator) and `audit-marketing` (marketing-team deep-dive — see setup below).
- **Marketing**: Bundled from [`coreyhaines31/marketingskills`](https://github.com/coreyhaines31/marketingskills) plugin v2.5.1 (upstream commit `8bfcdffb655f16e713940cd04fb08891899c47db`). Includes 45 skills: copywriting, cro, pricing, offers, emails, ad-creative, content-strategy, ads, seo-audit, marketing-plan, prospecting, public-relations, sms, and more. Supporting integration docs and CLIs live in `shared/tools/`; source metadata and license live in `shared/marketingskills/`.
- **Maker**: Bundled from [`coreyhaines31/makerskills`](https://github.com/coreyhaines31/makerskills) plugin v0.5.0 (upstream commit `0248a57dc69a0306b2254b88491260f6e395e1ce`). Includes 18 operator skills: decide, business-brainstorm, deep-research, domain, second-brain, company-brain, read-book, watch-video, jab-hook, slide-deck, pm, personal-cfo, company-cfo, paste, social-fetch, skillify, toolify, and loopify. Source metadata, changelog, and license live in `shared/makerskills/`.
- **Engineering**: nextjs, rails, prisma, drizzle, stripe, deployment, systematic-debugging, test-driven-development, and more
- **Design**: canvas-design, shadcn-ui, web-design-guidelines, brand-guidelines, theme-factory, and more

#### audit-marketing setup

The `/audit-marketing` skill needs a per-machine config file before first use. Create `~/.claude/audit-config.env`:

```bash
# Where audit folders live for each client (one folder per audit)
AUDIT_BASE_DIR="$HOME/audits"

# Ahrefs API key (used for SEO data, competitor analysis, keyword research)
AHREFS_API_KEY="your_ahrefs_key_here"

# Path to the Ahrefs API reference doc (shipped with the skill)
AHREFS_API_REFERENCE_PATH="$HOME/.claude/skills/audit-marketing/ahrefs_api_reference.md"

# Path to finished example audits (shipped with the skill)
AUDIT_EXAMPLES_PATH="$HOME/.claude/skills/audit-marketing/examples"
```

Both `ahrefs_api_reference.md` and `examples/` live inside the skill folder, so the paths above work as-is once `install.sh` has symlinked `shared/skills/` → `~/.claude/skills/`. Only `AUDIT_BASE_DIR` and `AHREFS_API_KEY` need real values from you.

#### makerskills setup

Maker skills keep personal/operator data out of this repo. For full use, set the base config location in your shell:

```bash
export MAKERSKILLS_CONFIG="$HOME/.config/makerskills"
```

Optional per-skill paths include `SECOND_BRAIN_VAULT`, `COMPANY_BRAIN_VAULT`, `COMPANY_CFO_ROOT`, and `SLIDE_DECK_REPO`. Skills that do not need persistent personal config, like `decide` and `paste`, can be used without this setup.

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
| Client repo enforcer | PreToolUse (Bash) | In client repos, blocks commits/branches outside `cf/*` prefix |
| Fork guard | PreToolUse (Bash) | Intercepts `gh repo fork` and asks if you meant to be added as a collaborator instead |
| Worktree recommender | PreToolUse (Bash) | When creating a branch with another Claude session already in the same repo, recommends a git worktree instead |
| Client tech stack | PreToolUse (Bash) | When creating a branch in a client repo, detects and displays the client's tech stack so you don't assume Next.js/Rails |
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
│   ├── skills/                  # All skills (canonical source)
│   ├── marketingskills/         # Vendored source metadata/license for marketing skills
│   ├── makerskills/             # Vendored source metadata/license for maker skills
│   └── tools/                   # Supporting docs/CLIs referenced by skills
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

> **Adding a CF client-delivery stage skill** (`positioning`, `wireframes`, `audit-marketing`, etc.)? Author it in the private [`cf-skills`](https://github.com/conversionfactory/cf-skills) repo instead — see the [CF team workflow skills](#cf-team-workflow-skills) section below. The rest of this section is for general skills authored directly in `agent-config`.

1. Create a directory in `shared/skills/your-skill-name/`
2. Add a `SKILL.md` with the skill definition
3. Optionally add `references/` and `evals/` subdirectories
4. Commit, push, and tell the team to run `./sync.sh`

Skills in `shared/skills/` are automatically available to Claude Code via the symlink.

### CF team workflow skills

The 14-stage CF delivery skills (`client-intake`, `positioning`, `brand-strategy`, ..., `audit`, `audit-marketing`) are authored in the private [`cf-skills`](https://github.com/conversionfactory/cf-skills) repo, where client examples and in-progress drafts can be staged before going public. When a skill lands in `cf-skills/main`, it gets copied into `shared/skills/` here.

The copy step is manual today — `cf-skills` is the canonical editing surface, `agent-config` is the distribution surface. Automation is a future improvement.

### Marketing skills

The marketing skills are vendored from [`coreyhaines31/marketingskills`](https://github.com/coreyhaines31/marketingskills). To refresh them, pull the latest upstream repo, copy `skills/*` into `shared/skills/`, and copy `tools/*` into `shared/tools/`.

Two names overlap with CF delivery-stage skills: `customer-research` and `launch`. Keep the upstream marketing workflow current, but preserve the CF client-delivery mode sections in those files so the Stage 1 and Stage 12 workflows remain available.

### Maker skills

The maker skills are vendored from [`coreyhaines31/makerskills`](https://github.com/coreyhaines31/makerskills). To refresh them, pull the latest upstream repo, copy `skills/*` into `shared/skills/`, and copy source metadata, changelog, and license into `shared/makerskills/`.

Maker skills currently have no name overlaps with CF or marketing skills.

## Recommended Tools (Optional)

These tools aren't installed by `install.sh` — run them per-project or globally as needed.

| Tool | What it does | Install |
|------|-------------|---------|
| [expect](https://expect.dev) | Browser-based automated testing for AI agents — scans code changes, generates a test strategy, and validates against a live browser with recordings | `npx -y expect-cli@latest init` |
| [emulate](https://emulate.dev) | Local drop-in replacements for Vercel, GitHub, Google, Slack, Apple, Microsoft, and AWS APIs — useful for testing in CI environments without network access | `npx emulate` |
| [vercel](https://vercel.com/docs/cli) | Deploy, manage env vars, link projects, and run `vercel dev` for local development with Vercel platform features | `npm i -g vercel@latest` |

## Recommended Plugins (Optional)

These Claude Code plugins aren't installed by `install.sh` — team members install them individually if useful for their work.

| Plugin | What it does | Install |
|--------|-------------|---------|
| [vercel](https://vercel.com/changelog/introducing-vercel-plugin-for-coding-agents) | Vercel-aware context — 47+ skills covering Next.js, AI SDK, Turborepo, real-time validation of deprecated patterns and stale APIs | `/plugin install vercel` |
| [compound-engineering](https://github.com/EveryInc/compound-engineering-plugin) | Engineering workflow agents — specialized agents for code review, architecture, data integrity, security, performance, and more | See repo for install instructions |
| [design-and-refine](https://github.com/0xdesign/design-plugin) | Iterative UI design — generates 5 variations, collects visual feedback, synthesizes a refined design with implementation plan | `/plugin install design-and-refine@design-plugins` |
| [agentation](https://www.agentation.com/) | Visual UI feedback — click elements in the browser, annotate bugs/feedback, get structured context (selectors, file paths, component hierarchy) for AI agents | `npm install agentation` |

**vercel** is essential if you deploy to Vercel — it dynamically injects Vercel knowledge into the agent's context, catches deprecated patterns, and includes specialist agents and slash commands for Vercel-specific tasks.

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
