---
description: Refactor code with specific improvements
argument-hint: [file-path] [focus-area]
---

## Context

Current code:
!`cat $1 2>/dev/null || echo "Please provide a file path"`

## Task

Refactor the code with focus on: $2

Guidelines:
1. **Preserve behavior**: No functional changes unless explicitly fixing bugs
2. **Small steps**: Make incremental improvements
3. **Explain each change**: Comment on why, not just what
4. **Consider**:
   - Readability and clarity
   - Reducing duplication
   - Better naming
   - Simplifying logic
   - Extracting reusable pieces (only if clearly beneficial)

Do NOT over-engineer. The goal is cleaner code, not more abstraction.
