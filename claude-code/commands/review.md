---
description: Review code for issues and improvements
argument-hint: [PR number [-R owner/repo] | file | git ref]
---

## Context

Code to review:
!`~/.claude/hooks/review-context.sh "$ARGUMENTS"`

If that came back empty or with an error, stop and load the right diff yourself (`gh pr diff <n> -R <owner/repo>`) before reviewing. Never pass an empty diff.

## Task

Review this code critically but constructively:

**Security**
- Input validation issues
- Injection vulnerabilities
- Exposed secrets or sensitive data

**Correctness**
- Logic errors
- Edge cases not handled
- Race conditions

**Maintainability**
- Unclear naming or structure
- Missing error handling
- Unnecessary complexity

**Performance** (only if obvious issues)
- N+1 queries
- Unnecessary loops
- Memory leaks

Format findings as:
- **Critical**: Must fix before merge
- **Warning**: Should fix
- **Suggestion**: Consider improving

Only after the review is complete and any Critical findings are fixed, mark it reviewed with the Bash tool, as its own command (the merge hook checks the whole command before any of it runs):
- PR review: `~/.claude/hooks/review-marker.sh --set <PR number> -R <owner/repo>`
- Current branch: `~/.claude/hooks/review-marker.sh --set`

Don't set the marker if the diff was empty or Critical findings remain.
