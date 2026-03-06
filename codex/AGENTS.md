# Codex CLI - Team Instructions

You are working with the Conversion Factory team. These are shared conventions that apply across all projects.

## REQUIRED

- **NEVER use `rm -rf`** - Use `trash` instead for safety
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

1. **Never work directly on `main` or `development`** - always create a feature or fix branch
2. **Start new work from `development`**: `git checkout development && git pull && git checkout -b feature/name`
3. **Branch naming**: `feature/short-description`, `fix/short-description`, `hotfix/short-description`
4. **When complete**: Review the code, then create PR from feature branch → `development`
5. **Before starting any git work**: `git branch --show-current`
6. **Never merge directly** into `main` or `development` — always use a PR
7. **Always review before merging** — run a code review before merging any PR

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
