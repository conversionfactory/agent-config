---
description: Generate tests for code
argument-hint: [file-path]
---

## Context

File to test:
!`cat $1 2>/dev/null || echo "Please provide a file path"`

Existing test patterns in project:
!`find . -name "*.test.*" -o -name "*.spec.*" | head -5 | xargs head -20 2>/dev/null || echo "No existing tests found"`

## Task

Generate comprehensive tests for the specified code:

1. **Analyze**: Identify functions, edge cases, and error conditions
2. **Match style**: Follow existing test patterns in this project
3. **Cover**:
   - Happy path scenarios
   - Edge cases (empty, null, boundary values)
   - Error handling
4. **Write**: Create the test file in the appropriate location
