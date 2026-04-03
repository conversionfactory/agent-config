#!/bin/bash
# When starting work in a client repo (creating a branch), detects the tech stack
# and surfaces it so the developer doesn't assume the wrong framework.
# Non-blocking — outputs info and exits 0.

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Only trigger on branch creation
echo "$CMD" | grep -qE '^\s*git\s+(checkout\s+-b|switch\s+-c)\b' || exit 0

# Check if we're in a git repo
git rev-parse --git-dir > /dev/null 2>&1 || exit 0

# Only run in client repos (non-CF)
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
if echo "$REMOTE_URL" | grep -qi "conversionfactory"; then
  exit 0
fi

# Detect tech stack
STACK=""

# JavaScript/TypeScript frameworks
if [ -f "package.json" ]; then
  DEPS=$(cat package.json | jq -r '(.dependencies // {}) + (.devDependencies // {}) | keys[]' 2>/dev/null)

  # Frameworks
  echo "$DEPS" | grep -qx "next" && STACK="$STACK  - Next.js\n"
  echo "$DEPS" | grep -qx "nuxt" && STACK="$STACK  - Nuxt\n"
  echo "$DEPS" | grep -qx "gatsby" && STACK="$STACK  - Gatsby\n"
  echo "$DEPS" | grep -qx "astro" && STACK="$STACK  - Astro\n"
  echo "$DEPS" | grep -qx "svelte" && STACK="$STACK  - Svelte\n"
  echo "$DEPS" | grep -qx "@sveltejs/kit" && STACK="$STACK  - SvelteKit\n"
  echo "$DEPS" | grep -qx "vue" && STACK="$STACK  - Vue.js\n"
  echo "$DEPS" | grep -qx "@angular/core" && STACK="$STACK  - Angular\n"
  echo "$DEPS" | grep -qx "remix" && STACK="$STACK  - Remix\n"
  echo "$DEPS" | grep -qx "@remix-run/react" && STACK="$STACK  - Remix\n"
  echo "$DEPS" | grep -qx "react" && ! echo "$DEPS" | grep -qx "next" && STACK="$STACK  - React (no Next.js)\n"

  # JS libraries (common ones that differ from our defaults)
  echo "$DEPS" | grep -qx "alpinejs" && STACK="$STACK  - Alpine.js ⚠️\n"
  echo "$DEPS" | grep -qx "jquery" && STACK="$STACK  - jQuery ⚠️\n"
  echo "$DEPS" | grep -qx "htmx.org" && STACK="$STACK  - htmx ⚠️\n"
  echo "$DEPS" | grep -qx "stimulus" && STACK="$STACK  - Stimulus ⚠️\n"
  echo "$DEPS" | grep -qx "@hotwired/stimulus" && STACK="$STACK  - Stimulus (Hotwire) ⚠️\n"
  echo "$DEPS" | grep -qx "@hotwired/turbo" && STACK="$STACK  - Turbo (Hotwire) ⚠️\n"
  echo "$DEPS" | grep -qx "turbo-rails" && STACK="$STACK  - Turbo Rails (Hotwire) ⚠️\n"

  # CSS
  echo "$DEPS" | grep -qx "tailwindcss" && STACK="$STACK  - Tailwind CSS\n"
  echo "$DEPS" | grep -qx "bootstrap" && STACK="$STACK  - Bootstrap ⚠️\n"
  echo "$DEPS" | grep -qx "bulma" && STACK="$STACK  - Bulma ⚠️\n"
  echo "$DEPS" | grep -qx "styled-components" && STACK="$STACK  - styled-components ⚠️\n"
  echo "$DEPS" | grep -qx "@emotion/react" && STACK="$STACK  - Emotion ⚠️\n"

  # CMS / site builders
  echo "$DEPS" | grep -qx "@sanity/client" && STACK="$STACK  - Sanity CMS\n"
  echo "$DEPS" | grep -qx "contentful" && STACK="$STACK  - Contentful\n"
  echo "$DEPS" | grep -qx "@prismic/client" && STACK="$STACK  - Prismic\n"
  echo "$DEPS" | grep -qx "payload" && STACK="$STACK  - Payload CMS\n"

  # ORMs / databases
  echo "$DEPS" | grep -qx "prisma" && STACK="$STACK  - Prisma\n"
  echo "$DEPS" | grep -qx "drizzle-orm" && STACK="$STACK  - Drizzle\n"
  echo "$DEPS" | grep -qx "mongoose" && STACK="$STACK  - Mongoose (MongoDB) ⚠️\n"
  echo "$DEPS" | grep -qx "sequelize" && STACK="$STACK  - Sequelize ⚠️\n"
  echo "$DEPS" | grep -qx "typeorm" && STACK="$STACK  - TypeORM ⚠️\n"
  echo "$DEPS" | grep -qx "knex" && STACK="$STACK  - Knex.js ⚠️\n"

  # Package manager
  [ -f "yarn.lock" ] && STACK="$STACK  - Yarn\n"
  [ -f "pnpm-lock.yaml" ] && STACK="$STACK  - pnpm\n"
  [ -f "bun.lockb" ] && STACK="$STACK  - Bun\n"
  [ -f "package-lock.json" ] && STACK="$STACK  - npm\n"
fi

# Ruby / Rails
if [ -f "Gemfile" ]; then
  STACK="$STACK  - Ruby"
  grep -q "rails" Gemfile && STACK="$STACK / Rails"
  STACK="$STACK\n"
  grep -q "hotwire" Gemfile && STACK="$STACK  - Hotwire ⚠️\n"
  grep -q "stimulus" Gemfile && STACK="$STACK  - Stimulus ⚠️\n"
  grep -q "turbo-rails" Gemfile && STACK="$STACK  - Turbo Rails ⚠️\n"
  grep -q "importmap" Gemfile && STACK="$STACK  - Importmap ⚠️\n"
  grep -q "jsbundling" Gemfile && STACK="$STACK  - jsbundling-rails\n"
  grep -q "cssbundling" Gemfile && STACK="$STACK  - cssbundling-rails\n"
fi

# PHP
if [ -f "composer.json" ]; then
  STACK="$STACK  - PHP"
  grep -q "laravel" composer.json && STACK="$STACK / Laravel"
  grep -q "wordpress" composer.json && STACK="$STACK / WordPress"
  STACK="$STACK ⚠️\n"
fi

# Python
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "Pipfile" ]; then
  STACK="$STACK  - Python"
  ([ -f "requirements.txt" ] && grep -q "django" requirements.txt) && STACK="$STACK / Django"
  ([ -f "requirements.txt" ] && grep -q "flask" requirements.txt) && STACK="$STACK / Flask"
  ([ -f "requirements.txt" ] && grep -q "fastapi" requirements.txt) && STACK="$STACK / FastAPI"
  STACK="$STACK ⚠️\n"
fi

# Static site / other indicators
[ -f "_config.yml" ] && STACK="$STACK  - Jekyll ⚠️\n"
[ -f "hugo.toml" ] || [ -f "hugo.yaml" ] && STACK="$STACK  - Hugo ⚠️\n"
[ -f "eleventy.config.js" ] || [ -f ".eleventy.js" ] && STACK="$STACK  - Eleventy (11ty) ⚠️\n"
[ -f "wp-config.php" ] && STACK="$STACK  - WordPress ⚠️\n"
[ -f "shopify.config.js" ] || [ -d "sections" ] && [ -f "config/settings_schema.json" ] && STACK="$STACK  - Shopify ⚠️\n"

# Build skill suggestions
SKILLS=""
SEARCH=""

if [ -f "package.json" ]; then
  DEPS=$(cat package.json | jq -r '(.dependencies // {}) + (.devDependencies // {}) | keys[]' 2>/dev/null)

  # Skills we have
  echo "$DEPS" | grep -qx "next" && SKILLS="$SKILLS  /nextjs\n"
  echo "$DEPS" | grep -qx "react" && SKILLS="$SKILLS  /react-best-practices\n"
  echo "$DEPS" | grep -qx "prisma" && SKILLS="$SKILLS  /prisma\n"
  echo "$DEPS" | grep -qx "drizzle-orm" && SKILLS="$SKILLS  /drizzle\n"
  echo "$DEPS" | grep -qx "stripe" && SKILLS="$SKILLS  /stripe\n"
  echo "$DEPS" | grep -qx "@stripe/stripe-js" && SKILLS="$SKILLS  /stripe\n"
  echo "$DEPS" | grep -qx "tailwindcss" && SKILLS="$SKILLS  /shadcn-ui  /web-design-guidelines\n"

  # Tech we don't have skills for — suggest fetching docs
  echo "$DEPS" | grep -qx "alpinejs" && SEARCH="$SEARCH  Alpine.js → fetch docs before writing code\n"
  echo "$DEPS" | grep -qx "vue" && SEARCH="$SEARCH  Vue.js → fetch docs before writing code\n"
  echo "$DEPS" | grep -qx "nuxt" && SEARCH="$SEARCH  Nuxt → fetch docs before writing code\n"
  echo "$DEPS" | grep -qx "@angular/core" && SEARCH="$SEARCH  Angular → fetch docs before writing code\n"
  echo "$DEPS" | grep -qx "svelte" && SEARCH="$SEARCH  Svelte → fetch docs before writing code\n"
  echo "$DEPS" | grep -qx "@sveltejs/kit" && SEARCH="$SEARCH  SvelteKit → fetch docs before writing code\n"
  echo "$DEPS" | grep -qx "astro" && SEARCH="$SEARCH  Astro → fetch docs before writing code\n"
  echo "$DEPS" | grep -qx "gatsby" && SEARCH="$SEARCH  Gatsby → fetch docs before writing code\n"
  echo "$DEPS" | grep -qx "jquery" && SEARCH="$SEARCH  jQuery → fetch docs before writing code\n"
  echo "$DEPS" | grep -qx "htmx.org" && SEARCH="$SEARCH  htmx → fetch docs before writing code\n"
  echo "$DEPS" | grep -qx "@hotwired/stimulus" && SEARCH="$SEARCH  Stimulus → fetch docs before writing code\n"
  echo "$DEPS" | grep -qx "stimulus" && SEARCH="$SEARCH  Stimulus → fetch docs before writing code\n"
  echo "$DEPS" | grep -qx "@hotwired/turbo" && SEARCH="$SEARCH  Turbo → fetch docs before writing code\n"
  echo "$DEPS" | grep -qx "bootstrap" && SEARCH="$SEARCH  Bootstrap CSS → fetch docs before writing code\n"
  echo "$DEPS" | grep -qx "styled-components" && SEARCH="$SEARCH  styled-components → fetch docs before writing code\n"
  echo "$DEPS" | grep -qx "@emotion/react" && SEARCH="$SEARCH  Emotion → fetch docs before writing code\n"
  echo "$DEPS" | grep -qx "mongoose" && SEARCH="$SEARCH  Mongoose/MongoDB → fetch docs before writing code\n"
  echo "$DEPS" | grep -qx "sequelize" && SEARCH="$SEARCH  Sequelize → fetch docs before writing code\n"
  echo "$DEPS" | grep -qx "typeorm" && SEARCH="$SEARCH  TypeORM → fetch docs before writing code\n"
fi

# Rails skill
if [ -f "Gemfile" ]; then
  grep -q "rails" Gemfile && SKILLS="$SKILLS  /rails\n"
  grep -q "stripe" Gemfile && SKILLS="$SKILLS  /stripe\n"
  (grep -q "hotwire\|stimulus\|turbo-rails" Gemfile) && SEARCH="$SEARCH  Hotwire/Stimulus/Turbo → fetch docs before writing code\n"
  grep -q "importmap" Gemfile && SEARCH="$SEARCH  importmap-rails → fetch docs before writing code\n"
fi

# No skill — suggest docs
[ -f "composer.json" ] && SEARCH="$SEARCH  PHP/Laravel → fetch docs before writing code\n"
([ -f "requirements.txt" ] || [ -f "pyproject.toml" ]) && SEARCH="$SEARCH  Python framework → fetch docs before writing code\n"
[ -f "_config.yml" ] && SEARCH="$SEARCH  Jekyll → fetch docs before writing code\n"
([ -f "hugo.toml" ] || [ -f "hugo.yaml" ]) && SEARCH="$SEARCH  Hugo → fetch docs before writing code\n"
([ -f "eleventy.config.js" ] || [ -f ".eleventy.js" ]) && SEARCH="$SEARCH  Eleventy → fetch docs before writing code\n"
[ -f "wp-config.php" ] && SEARCH="$SEARCH  WordPress → fetch docs before writing code\n"

# Always relevant for client work
SKILLS="$SKILLS  /web-design-guidelines  /security-best-practices\n"

if [ -n "$STACK" ]; then
  echo ""
  echo "📋 CLIENT TECH STACK DETECTED:"
  echo -e "$STACK"
  echo "⚠️ = differs from our default stack (Next.js/Rails + Tailwind + shadcn/ui)"
  echo "Write code using the CLIENT'S stack, not ours."

  if [ -n "$SKILLS" ]; then
    echo ""
    echo "💡 SUGGESTED SKILLS (run these before starting work):"
    echo -e "$SKILLS" | sort -u
  fi

  if [ -n "$SEARCH" ]; then
    echo ""
    echo "📚 NO SKILL AVAILABLE — fetch docs first (use context7 MCP or WebFetch):"
    echo -e "$SEARCH" | sort -u
  fi

  echo ""
fi

exit 0
