---
name: nextjs
description: Next.js App Router patterns with TypeScript. Use when building Next.js applications, creating routes, server components, API routes, or data fetching.
---

# Next.js App Router Skill

## File Structure

```
src/
├── app/
│   ├── layout.tsx          # Root layout
│   ├── page.tsx            # Home page
│   ├── loading.tsx         # Loading UI
│   ├── error.tsx           # Error boundary
│   ├── not-found.tsx       # 404 page
│   ├── (marketing)/        # Route group (no URL impact)
│   │   ├── about/page.tsx
│   │   └── pricing/page.tsx
│   ├── dashboard/
│   │   ├── layout.tsx      # Nested layout
│   │   ├── page.tsx
│   │   └── [id]/page.tsx   # Dynamic route
│   └── api/
│       └── webhooks/
│           └── stripe/route.ts
├── components/
│   ├── ui/                 # shadcn components
│   └── ...                 # App components
├── lib/
│   ├── db.ts              # Database client
│   ├── auth.ts            # Auth helpers
│   └── utils.ts           # Utilities
├── actions/               # Server actions
└── types/                 # TypeScript types
```

## Server Components (Default)

```tsx
// app/posts/page.tsx - Server Component (default)
import { db } from "@/lib/db"

export default async function PostsPage() {
  // Direct database access - no API needed
  const posts = await db.post.findMany({
    where: { published: true },
    orderBy: { createdAt: "desc" },
  })

  return (
    <div>
      <h1>Posts</h1>
      {posts.map((post) => (
        <PostCard key={post.id} post={post} />
      ))}
    </div>
  )
}
```

## Client Components

```tsx
"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"

export function Counter() {
  const [count, setCount] = useState(0)

  return (
    <div>
      <p>Count: {count}</p>
      <Button onClick={() => setCount(count + 1)}>
        Increment
      </Button>
    </div>
  )
}
```

## Server Actions

```tsx
// actions/posts.ts
"use server"

import { revalidatePath } from "next/cache"
import { redirect } from "next/navigation"
import { db } from "@/lib/db"
import { auth } from "@/lib/auth"
import { z } from "zod"

const CreatePostSchema = z.object({
  title: z.string().min(1).max(200),
  content: z.string().min(1),
})

export async function createPost(formData: FormData) {
  const session = await auth()
  if (!session?.user) {
    throw new Error("Unauthorized")
  }

  const validated = CreatePostSchema.parse({
    title: formData.get("title"),
    content: formData.get("content"),
  })

  const post = await db.post.create({
    data: {
      ...validated,
      userId: session.user.id,
    },
  })

  revalidatePath("/posts")
  redirect(`/posts/${post.id}`)
}

export async function deletePost(id: string) {
  const session = await auth()
  if (!session?.user) {
    throw new Error("Unauthorized")
  }

  await db.post.delete({
    where: { id, userId: session.user.id },
  })

  revalidatePath("/posts")
}
```

```tsx
// Using server actions in components
import { createPost, deletePost } from "@/actions/posts"

// In a form
<form action={createPost}>
  <input name="title" />
  <textarea name="content" />
  <Button type="submit">Create</Button>
</form>

// With useTransition for pending state
"use client"
import { useTransition } from "react"

function DeleteButton({ id }: { id: string }) {
  const [isPending, startTransition] = useTransition()

  return (
    <Button
      disabled={isPending}
      onClick={() => startTransition(() => deletePost(id))}
    >
      {isPending ? "Deleting..." : "Delete"}
    </Button>
  )
}
```

## API Routes

```tsx
// app/api/webhooks/stripe/route.ts
import { headers } from "next/headers"
import { NextResponse } from "next/server"
import Stripe from "stripe"

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!)

export async function POST(req: Request) {
  const body = await req.text()
  const signature = headers().get("stripe-signature")!

  let event: Stripe.Event

  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET!
    )
  } catch (err) {
    return NextResponse.json(
      { error: "Invalid signature" },
      { status: 400 }
    )
  }

  switch (event.type) {
    case "checkout.session.completed":
      await handleCheckoutComplete(event.data.object)
      break
    case "customer.subscription.updated":
      await handleSubscriptionUpdate(event.data.object)
      break
  }

  return NextResponse.json({ received: true })
}
```

## Dynamic Routes

```tsx
// app/posts/[slug]/page.tsx
import { notFound } from "next/navigation"
import { db } from "@/lib/db"

interface Props {
  params: { slug: string }
}

// Generate static paths at build time
export async function generateStaticParams() {
  const posts = await db.post.findMany({
    select: { slug: true },
  })
  return posts.map((post) => ({ slug: post.slug }))
}

// Generate metadata
export async function generateMetadata({ params }: Props) {
  const post = await db.post.findUnique({
    where: { slug: params.slug },
  })

  if (!post) return { title: "Not Found" }

  return {
    title: post.title,
    description: post.excerpt,
    openGraph: {
      title: post.title,
      images: [post.image],
    },
  }
}

export default async function PostPage({ params }: Props) {
  const post = await db.post.findUnique({
    where: { slug: params.slug },
    include: { author: true },
  })

  if (!post) notFound()

  return <PostContent post={post} />
}
```

## Middleware

```tsx
// middleware.ts
import { NextResponse } from "next/server"
import type { NextRequest } from "next/server"
import { auth } from "@/lib/auth"

export async function middleware(request: NextRequest) {
  const session = await auth()

  // Protect dashboard routes
  if (request.nextUrl.pathname.startsWith("/dashboard")) {
    if (!session) {
      return NextResponse.redirect(new URL("/login", request.url))
    }
  }

  return NextResponse.next()
}

export const config = {
  matcher: ["/dashboard/:path*", "/api/:path*"],
}
```

## Data Fetching Patterns

```tsx
// Parallel data fetching
async function Dashboard() {
  // These run in parallel
  const [user, posts, stats] = await Promise.all([
    getUser(),
    getPosts(),
    getStats(),
  ])

  return <DashboardContent user={user} posts={posts} stats={stats} />
}

// With Suspense boundaries
import { Suspense } from "react"

export default function Page() {
  return (
    <div>
      <h1>Dashboard</h1>
      <Suspense fallback={<StatsSkeleton />}>
        <Stats />
      </Suspense>
      <Suspense fallback={<PostsSkeleton />}>
        <RecentPosts />
      </Suspense>
    </div>
  )
}
```

## Environment Variables

```bash
# .env.local
DATABASE_URL="postgresql://..."
NEXTAUTH_SECRET="..."
NEXTAUTH_URL="http://localhost:3000"

# Public (exposed to browser)
NEXT_PUBLIC_APP_URL="http://localhost:3000"
```

```tsx
// Access in code
const dbUrl = process.env.DATABASE_URL          // Server only
const appUrl = process.env.NEXT_PUBLIC_APP_URL  // Client + Server
```
