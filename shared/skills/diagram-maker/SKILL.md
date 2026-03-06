---
name: diagram-maker
description: Creates visual diagrams to explain systems, flows, and architecture. Use when explaining how something works, documenting architecture, or when visual representation would aid understanding.
---

# Diagram Maker

Create clear, helpful diagrams to visualize concepts.

## Diagram Types

### Flowcharts (Mermaid)
```mermaid
flowchart TD
    A[Start] --> B{Decision}
    B -->|Yes| C[Action 1]
    B -->|No| D[Action 2]
    C --> E[End]
    D --> E
```

### Sequence Diagrams
```mermaid
sequenceDiagram
    participant U as User
    participant S as Server
    participant D as Database
    U->>S: Request
    S->>D: Query
    D-->>S: Results
    S-->>U: Response
```

### ASCII for Quick Sketches
```
┌─────────┐    ┌─────────┐    ┌─────────┐
│ Client  │───>│ Server  │───>│   DB    │
└─────────┘    └─────────┘    └─────────┘
     │              │              │
     └──────────────┴──────────────┘
            Request/Response
```

## Guidelines

1. **Match complexity to need**: Simple box diagram for simple concepts
2. **Label everything**: Every arrow and box should be clear
3. **Left-to-right or top-to-bottom**: Consistent flow direction
4. **Use mermaid** for diagrams that might be committed to docs
5. **Use ASCII** for quick inline explanations

## When to Create Diagrams

- Explaining data flow
- Architecture overview
- State machines
- API interactions
- Database relationships
- Process workflows
