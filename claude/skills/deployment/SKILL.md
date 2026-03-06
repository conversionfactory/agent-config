---
name: deployment
description: Deployment patterns for Vercel and Heroku. Use when deploying apps, configuring environments, setting up CI/CD, or troubleshooting deployments.
---

# Deployment Skill

## Vercel (Next.js)

### Project Setup

```bash
# Install Vercel CLI
npm i -g vercel

# Link project
vercel link

# Deploy preview
vercel

# Deploy to production
vercel --prod
```

### vercel.json Configuration

```json
{
  "buildCommand": "prisma generate && next build",
  "installCommand": "npm install",
  "framework": "nextjs",
  "regions": ["iad1"],
  "crons": [
    {
      "path": "/api/cron/daily",
      "schedule": "0 0 * * *"
    }
  ],
  "headers": [
    {
      "source": "/api/(.*)",
      "headers": [
        { "key": "Access-Control-Allow-Origin", "value": "*" }
      ]
    }
  ],
  "rewrites": [
    { "source": "/blog/:slug", "destination": "/posts/:slug" }
  ],
  "redirects": [
    { "source": "/old-page", "destination": "/new-page", "permanent": true }
  ]
}
```

### Environment Variables

```bash
# Add env var
vercel env add STRIPE_SECRET_KEY

# Pull env vars to .env.local
vercel env pull

# List env vars
vercel env ls
```

Environment variable scopes:
- **Production**: Only production deployments
- **Preview**: Preview deployments (PRs)
- **Development**: Local dev with `vercel dev`

### Edge Functions

```typescript
// app/api/edge/route.ts
export const runtime = "edge"

export async function GET(request: Request) {
  return new Response("Hello from the edge!")
}
```

### Cron Jobs

```typescript
// app/api/cron/daily/route.ts
import { NextResponse } from "next/server"

export async function GET(request: Request) {
  // Verify cron secret
  const authHeader = request.headers.get("authorization")
  if (authHeader !== `Bearer ${process.env.CRON_SECRET}`) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
  }

  // Your cron logic
  await runDailyTasks()

  return NextResponse.json({ success: true })
}
```

### Vercel Postgres / KV / Blob

```typescript
// Vercel Postgres
import { sql } from "@vercel/postgres"

const { rows } = await sql`SELECT * FROM users WHERE id = ${userId}`

// Vercel KV (Redis)
import { kv } from "@vercel/kv"

await kv.set("key", "value")
const value = await kv.get("key")

// Vercel Blob
import { put, del } from "@vercel/blob"

const { url } = await put("file.txt", "Hello!", { access: "public" })
await del(url)
```

### Preview Deployments

Each PR gets a unique URL:
- `https://project-git-branch-name-username.vercel.app`

Useful for:
- Testing changes before merge
- Sharing previews with stakeholders
- Running E2E tests against previews

---

## Heroku (Rails)

### Setup

```bash
# Install CLI
brew tap heroku/brew && brew install heroku

# Login
heroku login

# Create app
heroku create myapp-name

# Add Postgres
heroku addons:create heroku-postgresql:essential-0

# Add Redis (for Sidekiq)
heroku addons:create heroku-redis:mini
```

### Procfile

```procfile
# Procfile
web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -C config/sidekiq.yml
release: bundle exec rails db:migrate
```

### Config Vars

```bash
# Set env vars
heroku config:set RAILS_ENV=production
heroku config:set SECRET_KEY_BASE=$(rails secret)
heroku config:set STRIPE_SECRET_KEY=sk_live_...

# View all config
heroku config

# Get database URL
heroku config:get DATABASE_URL
```

### Deployment

```bash
# Deploy
git push heroku main

# Deploy specific branch
git push heroku feature-branch:main

# Run migrations
heroku run rails db:migrate

# Open Rails console
heroku run rails console

# View logs
heroku logs --tail

# Restart dynos
heroku restart
```

### Buildpacks

```bash
# List buildpacks
heroku buildpacks

# Add Node.js (for assets)
heroku buildpacks:add --index 1 heroku/nodejs
heroku buildpacks:add --index 2 heroku/ruby
```

### Database Operations

```bash
# Backup database
heroku pg:backups:capture

# Download backup
heroku pg:backups:download

# Restore from backup
heroku pg:backups:restore

# Reset database (careful!)
heroku pg:reset DATABASE_URL

# Run SQL
heroku pg:psql
```

### Scaling

```bash
# Scale web dynos
heroku ps:scale web=2

# Scale workers
heroku ps:scale worker=1

# View dyno info
heroku ps
```

### Review Apps

In `app.json`:
```json
{
  "name": "My App",
  "scripts": {
    "postdeploy": "bundle exec rails db:migrate db:seed"
  },
  "env": {
    "RAILS_ENV": "production",
    "RACK_ENV": "production"
  },
  "addons": ["heroku-postgresql:essential-0"],
  "buildpacks": [
    { "url": "heroku/nodejs" },
    { "url": "heroku/ruby" }
  ]
}
```

---

## Common Patterns

### Database URLs

```bash
# Neon
DATABASE_URL="postgresql://user:pass@ep-xxx.us-east-1.aws.neon.tech/dbname?sslmode=require"

# Supabase
DATABASE_URL="postgresql://postgres:pass@db.xxx.supabase.co:5432/postgres"

# Heroku Postgres
DATABASE_URL="postgres://user:pass@ec2-xxx.compute-1.amazonaws.com:5432/dbname"
```

### Health Checks

```typescript
// Next.js: app/api/health/route.ts
export async function GET() {
  try {
    // Check database connection
    await db.$queryRaw`SELECT 1`
    return Response.json({ status: "ok" })
  } catch (error) {
    return Response.json({ status: "error" }, { status: 500 })
  }
}
```

```ruby
# Rails: config/routes.rb
get "/health", to: proc { [200, {}, ["OK"]] }
```

### CI/CD with GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # For Vercel
      - uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: "--prod"

      # For Heroku
      - uses: akhileshns/heroku-deploy@v3.13.15
        with:
          heroku_api_key: ${{ secrets.HEROKU_API_KEY }}
          heroku_app_name: "your-app-name"
          heroku_email: "your@email.com"
```

### Secrets Management

| Platform | Secret storage |
|----------|----------------|
| Vercel | Project Settings > Environment Variables |
| Heroku | Config Vars via CLI or Dashboard |
| GitHub | Repository Settings > Secrets |

### Troubleshooting

```bash
# Vercel: Check build logs
vercel logs [deployment-url]

# Heroku: Tail logs
heroku logs --tail --app myapp

# Check dyno status
heroku ps --app myapp

# Run one-off command
heroku run bash --app myapp
```
