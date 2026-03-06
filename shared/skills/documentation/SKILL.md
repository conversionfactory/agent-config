---
name: documentation
description: Writes clear technical documentation. Use when creating READMEs, API docs, code comments, or any technical writing.
---

# Documentation Skill

Write documentation that developers actually want to read.

## README Structure

```markdown
# Project Name

One-line description of what this does.

## Quick Start

\`\`\`bash
# Minimal steps to get running
npm install
npm start
\`\`\`

## Features

- Feature 1
- Feature 2

## Usage

### Basic Example
\`\`\`javascript
// Most common use case
\`\`\`

### Advanced Usage
\`\`\`javascript
// Less common but important patterns
\`\`\`

## Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `foo`  | `bar`   | Does X      |

## API Reference

See [API.md](./API.md) for full reference.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md)
```

## Principles

1. **Lead with examples**: Show, don't tell
2. **Progressive disclosure**: Simple first, details later
3. **Keep it updated**: Outdated docs are worse than none
4. **Test your docs**: Try following them from scratch

## Code Comments

```javascript
// Good: Explains WHY
// Cache user lookup to avoid N+1 queries in the loop below
const userCache = new Map();

// Bad: Explains WHAT (the code already shows this)
// Set x to 5
const x = 5;
```

## When to Document

- Public APIs - always
- Non-obvious business logic - yes
- Complex algorithms - yes
- Standard patterns - no
- Self-explanatory code - no
