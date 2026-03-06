---
name: drizzle
description: Drizzle ORM patterns for database operations. Use when working with Drizzle schema, migrations, queries, or type-safe database access.
---

# Drizzle ORM Skill

## Setup

```bash
npm install drizzle-orm
npm install -D drizzle-kit

# For Postgres (Neon, Supabase, etc.)
npm install @neondatabase/serverless
# or
npm install postgres
# or
npm install @vercel/postgres
```

## Schema Definition

```typescript
// db/schema.ts
import {
  pgTable,
  text,
  timestamp,
  boolean,
  integer,
  pgEnum,
  uuid,
  index,
  uniqueIndex,
} from "drizzle-orm/pg-core"
import { relations } from "drizzle-orm"

// Enums
export const subscriptionStatusEnum = pgEnum("subscription_status", [
  "active",
  "canceled",
  "past_due",
  "trialing",
])

// Users table
export const users = pgTable(
  "users",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    email: text("email").notNull().unique(),
    name: text("name"),
    createdAt: timestamp("created_at").defaultNow().notNull(),
    updatedAt: timestamp("updated_at").defaultNow().notNull(),
  },
  (table) => ({
    emailIdx: uniqueIndex("users_email_idx").on(table.email),
  })
)

// Profiles table (one-to-one)
export const profiles = pgTable("profiles", {
  id: uuid("id").defaultRandom().primaryKey(),
  bio: text("bio"),
  avatar: text("avatar"),
  userId: uuid("user_id")
    .notNull()
    .unique()
    .references(() => users.id, { onDelete: "cascade" }),
})

// Posts table
export const posts = pgTable(
  "posts",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    title: text("title").notNull(),
    content: text("content"),
    slug: text("slug").notNull().unique(),
    published: boolean("published").default(false).notNull(),
    authorId: uuid("author_id")
      .notNull()
      .references(() => users.id, { onDelete: "cascade" }),
    createdAt: timestamp("created_at").defaultNow().notNull(),
    updatedAt: timestamp("updated_at").defaultNow().notNull(),
  },
  (table) => ({
    authorIdx: index("posts_author_idx").on(table.authorId),
    slugIdx: uniqueIndex("posts_slug_idx").on(table.slug),
  })
)

// Categories (many-to-many)
export const categories = pgTable("categories", {
  id: uuid("id").defaultRandom().primaryKey(),
  name: text("name").notNull().unique(),
})

export const postsToCategories = pgTable(
  "posts_to_categories",
  {
    postId: uuid("post_id")
      .notNull()
      .references(() => posts.id, { onDelete: "cascade" }),
    categoryId: uuid("category_id")
      .notNull()
      .references(() => categories.id, { onDelete: "cascade" }),
  },
  (table) => ({
    pk: primaryKey({ columns: [table.postId, table.categoryId] }),
  })
)

// Subscriptions
export const subscriptions = pgTable("subscriptions", {
  id: uuid("id").defaultRandom().primaryKey(),
  stripeSubscriptionId: text("stripe_subscription_id").notNull().unique(),
  stripePriceId: text("stripe_price_id").notNull(),
  status: subscriptionStatusEnum("status").default("trialing").notNull(),
  currentPeriodEnd: timestamp("current_period_end").notNull(),
  userId: uuid("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  createdAt: timestamp("created_at").defaultNow().notNull(),
})

// Relations
export const usersRelations = relations(users, ({ one, many }) => ({
  profile: one(profiles, {
    fields: [users.id],
    references: [profiles.userId],
  }),
  posts: many(posts),
  subscriptions: many(subscriptions),
}))

export const postsRelations = relations(posts, ({ one, many }) => ({
  author: one(users, {
    fields: [posts.authorId],
    references: [users.id],
  }),
  categories: many(postsToCategories),
}))

export const categoriesRelations = relations(categories, ({ many }) => ({
  posts: many(postsToCategories),
}))

export const postsToCategoriesRelations = relations(
  postsToCategories,
  ({ one }) => ({
    post: one(posts, {
      fields: [postsToCategories.postId],
      references: [posts.id],
    }),
    category: one(categories, {
      fields: [postsToCategories.categoryId],
      references: [categories.id],
    }),
  })
)
```

## Client Setup

```typescript
// db/index.ts (Neon Serverless)
import { neon } from "@neondatabase/serverless"
import { drizzle } from "drizzle-orm/neon-http"
import * as schema from "./schema"

const sql = neon(process.env.DATABASE_URL!)
export const db = drizzle(sql, { schema })

// db/index.ts (Postgres.js - for Supabase, etc.)
import { drizzle } from "drizzle-orm/postgres-js"
import postgres from "postgres"
import * as schema from "./schema"

const client = postgres(process.env.DATABASE_URL!)
export const db = drizzle(client, { schema })

// db/index.ts (Vercel Postgres)
import { drizzle } from "drizzle-orm/vercel-postgres"
import { sql } from "@vercel/postgres"
import * as schema from "./schema"

export const db = drizzle(sql, { schema })
```

## Common Queries

```typescript
import { db } from "@/db"
import { users, posts, profiles } from "@/db/schema"
import { eq, and, or, like, desc, asc, sql, count, ilike } from "drizzle-orm"

// Insert
const [user] = await db
  .insert(users)
  .values({ email: "user@example.com", name: "John" })
  .returning()

// Insert many
await db.insert(posts).values([
  { title: "Post 1", slug: "post-1", authorId: user.id },
  { title: "Post 2", slug: "post-2", authorId: user.id },
])

// Select with conditions
const publishedPosts = await db
  .select()
  .from(posts)
  .where(eq(posts.published, true))
  .orderBy(desc(posts.createdAt))
  .limit(10)
  .offset(0)

// Select with joins
const postsWithAuthors = await db
  .select({
    id: posts.id,
    title: posts.title,
    authorName: users.name,
    authorEmail: users.email,
  })
  .from(posts)
  .leftJoin(users, eq(posts.authorId, users.id))
  .where(eq(posts.published, true))

// Using relations (query API)
const usersWithPosts = await db.query.users.findMany({
  with: {
    posts: {
      where: eq(posts.published, true),
      orderBy: [desc(posts.createdAt)],
      limit: 5,
    },
    profile: true,
  },
})

const user = await db.query.users.findFirst({
  where: eq(users.email, "user@example.com"),
  with: { profile: true, posts: true },
})

// Complex where conditions
const searchResults = await db
  .select()
  .from(posts)
  .where(
    and(
      eq(posts.published, true),
      or(
        ilike(posts.title, `%${query}%`),
        ilike(posts.content, `%${query}%`)
      )
    )
  )

// Update
const [updated] = await db
  .update(users)
  .set({ name: "New Name", updatedAt: new Date() })
  .where(eq(users.id, userId))
  .returning()

// Upsert (on conflict)
await db
  .insert(users)
  .values({ email, name })
  .onConflictDoUpdate({
    target: users.email,
    set: { name, updatedAt: new Date() },
  })

// Delete
await db.delete(posts).where(eq(posts.id, postId))

// Aggregations
const [stats] = await db
  .select({
    total: count(),
    published: count(sql`CASE WHEN ${posts.published} THEN 1 END`),
  })
  .from(posts)

// Transactions
await db.transaction(async (tx) => {
  const [user] = await tx
    .insert(users)
    .values({ email, name })
    .returning()

  await tx.insert(profiles).values({ userId: user.id, bio: "" })
})
```

## Migrations

```typescript
// drizzle.config.ts
import type { Config } from "drizzle-kit"

export default {
  schema: "./db/schema.ts",
  out: "./db/migrations",
  dialect: "postgresql",
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
} satisfies Config
```

```bash
# Generate migration
npx drizzle-kit generate

# Push schema directly (dev)
npx drizzle-kit push

# Apply migrations
npx drizzle-kit migrate

# Open Drizzle Studio
npx drizzle-kit studio
```

## Type Inference

```typescript
import { InferSelectModel, InferInsertModel } from "drizzle-orm"

// Infer types from schema
type User = InferSelectModel<typeof users>
type NewUser = InferInsertModel<typeof users>
type Post = InferSelectModel<typeof posts>
type NewPost = InferInsertModel<typeof posts>

// Use in functions
async function createUser(data: NewUser): Promise<User> {
  const [user] = await db.insert(users).values(data).returning()
  return user
}
```
