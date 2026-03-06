# Claude Code - Global Instructions

You are working with Corey Haines. These are global preferences that apply across all projects.

## REQUIRED

- **NEVER use `rm -rf`** - it's blocked by the command-validator hook for safety
- Use `trash` instead: `trash folder-name` or `trash file.txt`
  - Works exactly like `rm -rf` but moves to Trash instead of permanent deletion
- **Always run the project's lint command after making code changes** to catch and fix lint errors before committing

## Tech Stacks

### Primary Stacks
- **Ruby on Rails** - Backend/full-stack apps
- **Next.js** (App Router) - React apps with TypeScript

### Next.js Stack
- **UI**: shadcn/ui + Tailwind CSS
- **Database**: Postgres (Neon, Supabase, or Convex)
- **ORM**: Prisma or Drizzle
- **Auth**: NextAuth.js / Auth.js
- **Payments**: Stripe
- **Browser Automation**: agent-browser (Vercel's CLI for AI agents)

### Rails Stack
- **Database**: PostgreSQL
- **Background Jobs**: Sidekiq or GoodJob
- **Auth**: Devise
- **Testing**: RSpec
- **Payments**: Stripe

## Coding Preferences

### General
- Write clean, simple code. Avoid over-engineering.
- Prefer explicit over clever. Code should be readable.
- Follow existing patterns in the codebase.
- Don't add features, abstractions, or "improvements" beyond what's asked.
- Don't add comments unless the logic is non-obvious.
- Use TypeScript for all JS/TS code. Prefer `type` over `interface`.

### Rails Conventions
- Follow Rails conventions strictly (fat models, skinny controllers)
- Use service objects for complex business logic (`app/services/`)
- Prefer scopes over class methods for queries
- Use `before_action` sparingly
- Write request specs over controller specs

### Next.js Conventions
- Use Server Components by default, Client Components only when needed
- Use Server Actions for mutations
- Colocate components with their routes when possible
- Use `@/` path alias for imports
- Validate with Zod

### UI/Styling
- Use shadcn/ui components as the foundation
- Follow Tailwind CSS patterns
- Mobile-first responsive design
- Use `cn()` utility for conditional classes

### Database
- Always add indexes for foreign keys and frequently queried columns
- Use UUIDs for primary keys in new projects
- Write migrations that are reversible
- Use transactions for multi-step operations

### Testing
- Write tests for critical paths and edge cases
- Don't over-test obvious code
- Match existing test patterns in the project

## Communication Style

- Be direct and concise
- Skip unnecessary preamble
- Don't over-explain unless asked
- If something is unclear, ask rather than assume

## Git Workflow

**IMPORTANT**: Always follow this branching strategy.

### Branch Structure
```
main (production)
  └── development (primary working branch)
        ├── feature/add-user-auth
        ├── feature/stripe-webhooks
        ├── fix/login-redirect
        └── fix/null-pointer-error
```

### Workflow Rules

1. **Never work directly on `main` or `development`**
   - Always create a feature or fix branch

2. **Start new work from `development`**
   ```bash
   git checkout development
   git pull origin development
   git checkout -b feature/my-feature
   # or
   git checkout -b fix/bug-description
   ```

3. **Branch naming conventions**
   - Features: `feature/short-description`
   - Bug fixes: `fix/short-description`
   - Hotfixes (urgent): `hotfix/short-description`

4. **When work is complete**
   - Run `/review` to review the code (required before merging)
   - Create PR from feature branch → `development`
   - After merge, delete the feature branch
   - Return to `development` for next task
   ```bash
   git checkout development
   git pull origin development
   ```

5. **Releasing to production**
   - Create PR from `development` → `main`
   - After merge to main, switch back to `development`
   ```bash
   git checkout development
   git pull origin development
   ```

6. **Before starting any git work**, check current branch:
   ```bash
   git branch --show-current
   ```
   - If on `main` or `development`, create a new branch first
   - If on a feature/fix branch, continue working

### Enforced Rules (via hooks)

- **No direct merges into `main` or `development`** — `git merge` is blocked on these branches. Open a PR instead.
- **No merging PRs without a review** — `gh pr merge` is blocked until `/review` has been run on the current branch.

### Quick Reference
| Action | Command |
|--------|---------|
| Start new feature | `git checkout development && git pull && git checkout -b feature/name` |
| Start bug fix | `git checkout development && git pull && git checkout -b fix/name` |
| Review before merge | `/review` (required before `gh pr merge`) |
| After PR merged | `git checkout development && git pull` |
| Check current branch | `git branch --show-current` |

## Other Workflow Preferences

- Commit messages should be concise and describe the "why"
- Create focused PRs that do one thing well
- Run tests and linting before committing
- Use browser automation to validate UI changes when helpful (agent-browser for Next.js, dev-browser for others)

## Node.js/Yarn Debugging

When yarn or node commands fail or behave unexpectedly:

- **Use `DEBUG=*` for verbose output**: `DEBUG=* yarn dev`, `DEBUG=* yarn build`, etc.
- This exposes debug logs from most Node.js libraries and often reveals the actual issue
- For more targeted debugging, use specific namespaces: `DEBUG=express:*`, `DEBUG=next:*`
- Also useful: `NODE_OPTIONS='--inspect'` for Chrome DevTools debugging

## Project Types

I build:
- **Content sites** - SEO-focused, static-ish pages
- **B2B SaaS** - Dashboards, subscriptions, team features
- **Tools with AI features** - Chat interfaces, content generation
- **Apps with scraping** - Data collection and processing

## Common Patterns

### Stripe Integration
- Always verify webhook signatures
- Store `stripeCustomerId` on User model
- Use Stripe Customer Portal for subscription management
- Handle webhook events: `checkout.session.completed`, `customer.subscription.updated`, `customer.subscription.deleted`, `invoice.payment_failed`

### AI Features
- Use Vercel AI SDK for streaming in Next.js
- Implement rate limiting on AI endpoints
- Cache responses where appropriate
- Use structured output (Zod schemas) when extracting data

### Scraping
- Check for APIs before scraping HTML
- Respect rate limits and robots.txt
- Use Playwright for JS-rendered content, Cheerio for static HTML
- Store scraped data with timestamps for freshness tracking

## Commands Available

Use these slash commands:
- `/commit` - Create a git commit with good message
- `/pr` - Create a pull request
- `/review` - Code review for issues
- `/test` - Generate tests
- `/explain` - Explain code with diagrams
- `/refactor` - Refactor with focus area
- `/debug` - Systematic debugging

## MCP Servers Available

- **postgres** - Query databases directly (needs DATABASE_URL)
- **github** - PR/issue management
- **stripe** - Query customers and subscriptions (needs STRIPE_SECRET_KEY)
- **dev-browser** - Browser automation for testing (general)
- **agent-browser** - Vercel's browser CLI for Next.js projects (preferred for Next.js)
  - Install: `npm install -g agent-browser && agent-browser install`
  - Uses semantic locators and accessibility tree snapshots
  - Supports sessions for isolated browser instances

## File Organization

### Next.js Projects
```
src/
├── app/           # Routes and layouts
├── components/
│   ├── ui/        # shadcn components
│   └── ...        # App-specific components
├── lib/           # Utilities, db client, auth
├── actions/       # Server actions
└── types/         # TypeScript types
```

### Rails Projects
```
app/
├── controllers/
├── models/
├── views/
├── services/      # Business logic
├── jobs/          # Background jobs
└── components/    # ViewComponents (if used)
```

## Deployment

- **Next.js**: Vercel (primary), sometimes Railway
- **Rails**: Heroku (primary), sometimes Render
- Environment variables go in platform dashboard, not committed
- Use preview deployments for PR review
