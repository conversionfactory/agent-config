---
description: Review code for issues and improvements
argument-hint: [file-or-diff]
---

## Context

Code to review:
!`if [ -f "$1" ]; then cat "$1"; else git diff $1 2>/dev/null || echo "Provide a file path or git ref"; fi`

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
