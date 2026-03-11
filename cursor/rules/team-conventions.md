---
description: Conversion Factory team coding conventions and preferences
---

# Team Conventions

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

## Git Workflow

**IMPORTANT**: Always follow this branching strategy.

### Branch Structure
```
main (production)
  └── development (primary working branch)
        ├── feature/add-user-auth
        └── fix/login-redirect
```

### Rules
1. **Never work directly on `main` or `development`** - always create a feature or fix branch
2. **Start new work from `development`**: `git checkout development && git pull && git checkout -b feature/name`
3. **Branch naming**: `feature/short-description`, `fix/short-description`, `hotfix/short-description`
4. **When complete**: Review the code, then create PR from feature branch → `development`
5. **Never merge directly** into `main` or `development` — always use a PR
6. **Always review before merging** — run a code review before merging any PR

## Development Workflow

The team follows a 5-step workflow: pick/create issue → plan → implement → review → ship. Always include the issue number in branch names (`feature/123-description`). Keep work focused: one issue = one branch = one PR.

## GitHub Issues

Use GitHub Issues to coordinate work across the team. Check open issues before starting work. Self-assign issues you're working on. Branch names must include the issue number. Link PRs to issues with "closes #123" in the description.

## Portless (Local Dev URLs)

Use portless to start dev servers — `npx portless myapp next dev` instead of bare `next dev`. This gives each app a stable URL (`myapp.localhost:1355`) and avoids port conflicts. Never hardcode port numbers. If a project's dev script uses portless, respect it.

## Common Patterns

### Stripe Integration
- Always verify webhook signatures
- Store `stripeCustomerId` on User model
- Use Stripe Customer Portal for subscription management

### AI Features
- Use Vercel AI SDK for streaming in Next.js
- Implement rate limiting on AI endpoints
- Use structured output (Zod schemas) when extracting data

## Communication Style

- Be direct and concise
- Skip unnecessary preamble
- If something is unclear, ask rather than assume
