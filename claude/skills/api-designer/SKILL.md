---
name: api-designer
description: Designs REST and GraphQL APIs with best practices. Use when creating new endpoints, designing API contracts, or reviewing API design.
---

# API Designer

Design clean, consistent, and developer-friendly APIs.

## REST Conventions

### URL Structure
```
GET    /resources          # List
GET    /resources/:id      # Get one
POST   /resources          # Create
PUT    /resources/:id      # Full update
PATCH  /resources/:id      # Partial update
DELETE /resources/:id      # Delete

# Nested resources (when truly nested)
GET    /users/:id/posts    # User's posts

# Actions (when not CRUD)
POST   /resources/:id/actions/publish
```

### Response Format
```json
{
  "data": { ... },
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 100
  }
}
```

### Error Format
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human readable message",
    "details": [
      { "field": "email", "message": "Invalid format" }
    ]
  }
}
```

### Status Codes
- `200` Success
- `201` Created
- `204` No Content (successful delete)
- `400` Bad Request (client error)
- `401` Unauthorized (not authenticated)
- `403` Forbidden (not authorized)
- `404` Not Found
- `422` Unprocessable Entity (validation failed)
- `500` Internal Server Error

## GraphQL Patterns

### Query Structure
```graphql
type Query {
  user(id: ID!): User
  users(filter: UserFilter, pagination: Pagination): UserConnection!
}

type UserConnection {
  edges: [UserEdge!]!
  pageInfo: PageInfo!
}
```

### Mutations
```graphql
type Mutation {
  createUser(input: CreateUserInput!): CreateUserPayload!
}

type CreateUserPayload {
  user: User
  errors: [Error!]!
}
```

## Design Principles

1. **Consistency**: Same patterns everywhere
2. **Predictability**: No surprises
3. **Documentation**: OpenAPI or GraphQL schema
4. **Versioning**: URL prefix (`/v1/`) or header
5. **Pagination**: Always paginate lists
6. **Filtering**: Query params for REST, args for GraphQL
