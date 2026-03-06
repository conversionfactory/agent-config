---
name: prisma
description: Prisma ORM patterns for database operations. Use when working with Prisma schema, migrations, queries, or database modeling.
---

# Prisma ORM Skill

## Setup

```bash
npm install prisma @prisma/client
npx prisma init
```

## Schema Patterns

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// User with relations
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  // Relations
  posts         Post[]
  profile       Profile?
  subscriptions Subscription[]

  @@index([email])
  @@map("users")
}

model Profile {
  id     String @id @default(cuid())
  bio    String?
  avatar String?
  userId String @unique
  user   User   @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("profiles")
}

model Post {
  id        String   @id @default(cuid())
  title     String
  content   String?
  slug      String   @unique
  published Boolean  @default(false)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  authorId String
  author   User   @relation(fields: [authorId], references: [id], onDelete: Cascade)

  categories Category[]
  tags       Tag[]

  @@index([authorId])
  @@index([slug])
  @@map("posts")
}

// Many-to-many
model Category {
  id    String @id @default(cuid())
  name  String @unique
  posts Post[]

  @@map("categories")
}

model Tag {
  id    String @id @default(cuid())
  name  String @unique
  posts Post[]

  @@map("tags")
}

// Subscription with enum
enum SubscriptionStatus {
  ACTIVE
  CANCELED
  PAST_DUE
  TRIALING
}

model Subscription {
  id                   String             @id @default(cuid())
  stripeSubscriptionId String             @unique
  stripePriceId        String
  status               SubscriptionStatus @default(TRIALING)
  currentPeriodEnd     DateTime
  createdAt            DateTime           @default(now())
  updatedAt            DateTime           @updatedAt

  userId String
  user   User   @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId])
  @@map("subscriptions")
}
```

## Client Setup (Next.js)

```typescript
// lib/db.ts
import { PrismaClient } from "@prisma/client"

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const db =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === "development"
      ? ["query", "error", "warn"]
      : ["error"],
  })

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = db
```

## Common Queries

```typescript
// Create
const user = await db.user.create({
  data: {
    email: "user@example.com",
    name: "John",
    profile: {
      create: { bio: "Hello!" }, // Nested create
    },
  },
  include: { profile: true },
})

// Find unique
const user = await db.user.findUnique({
  where: { email: "user@example.com" },
  include: {
    posts: { where: { published: true } },
    profile: true,
  },
})

// Find many with filtering
const posts = await db.post.findMany({
  where: {
    published: true,
    author: { email: { contains: "@company.com" } },
    OR: [
      { title: { contains: query, mode: "insensitive" } },
      { content: { contains: query, mode: "insensitive" } },
    ],
  },
  orderBy: { createdAt: "desc" },
  take: 10,
  skip: page * 10,
  include: {
    author: { select: { name: true, email: true } },
    _count: { select: { categories: true } },
  },
})

// Update
const updated = await db.user.update({
  where: { id: userId },
  data: {
    name: "New Name",
    profile: {
      upsert: {
        create: { bio: "New bio" },
        update: { bio: "Updated bio" },
      },
    },
  },
})

// Upsert
const user = await db.user.upsert({
  where: { email },
  create: { email, name },
  update: { name },
})

// Delete
await db.post.delete({ where: { id: postId } })

// Delete many
await db.post.deleteMany({
  where: { authorId: userId, published: false },
})

// Transactions
const [post, user] = await db.$transaction([
  db.post.create({ data: postData }),
  db.user.update({ where: { id: userId }, data: { postCount: { increment: 1 } } }),
])

// Interactive transaction
await db.$transaction(async (tx) => {
  const user = await tx.user.findUnique({ where: { id: userId } })
  if (!user) throw new Error("User not found")

  await tx.post.create({ data: { ...postData, authorId: user.id } })
})

// Aggregations
const stats = await db.post.aggregate({
  where: { published: true },
  _count: true,
  _avg: { views: true },
})

const groupedPosts = await db.post.groupBy({
  by: ["authorId"],
  _count: { id: true },
  orderBy: { _count: { id: "desc" } },
})
```

## Migrations

```bash
# Create migration from schema changes
npx prisma migrate dev --name add_posts_table

# Apply migrations in production
npx prisma migrate deploy

# Reset database (dev only)
npx prisma migrate reset

# Generate client after schema change
npx prisma generate

# View database in browser
npx prisma studio
```

## Seeding

```typescript
// prisma/seed.ts
import { PrismaClient } from "@prisma/client"

const prisma = new PrismaClient()

async function main() {
  await prisma.user.upsert({
    where: { email: "admin@example.com" },
    update: {},
    create: {
      email: "admin@example.com",
      name: "Admin",
      posts: {
        create: [
          { title: "First Post", slug: "first-post", published: true },
          { title: "Draft", slug: "draft", published: false },
        ],
      },
    },
  })
}

main()
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })
  .finally(() => prisma.$disconnect())
```

```json
// package.json
{
  "prisma": {
    "seed": "tsx prisma/seed.ts"
  }
}
```

## Type-Safe Helpers

```typescript
// Get return type of a query
type UserWithPosts = Prisma.UserGetPayload<{
  include: { posts: true; profile: true }
}>

// Input types
type CreateUserInput = Prisma.UserCreateInput
type UpdateUserInput = Prisma.UserUpdateInput

// Validator helper
import { Prisma } from "@prisma/client"

const userWithPosts = Prisma.validator<Prisma.UserDefaultArgs>()({
  include: { posts: true },
})

type UserWithPosts = Prisma.UserGetPayload<typeof userWithPosts>
```
