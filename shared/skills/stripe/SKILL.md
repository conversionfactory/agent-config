---
name: stripe
description: Stripe payments, subscriptions, and billing integration. Use when implementing checkout, managing subscriptions, handling webhooks, or building pricing pages.
---

# Stripe Integration Skill

## Setup

```bash
npm install stripe @stripe/stripe-js @stripe/react-stripe-js
```

```tsx
// lib/stripe.ts
import Stripe from "stripe"

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: "2024-11-20.acacia",
  typescript: true,
})

// lib/stripe-client.ts (for client-side)
import { loadStripe } from "@stripe/stripe-js"

export const getStripe = () => {
  return loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!)
}
```

## Checkout Session (One-time or Subscription)

```tsx
// app/api/checkout/route.ts
import { NextResponse } from "next/server"
import { stripe } from "@/lib/stripe"
import { auth } from "@/lib/auth"

export async function POST(req: Request) {
  const session = await auth()
  if (!session?.user) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
  }

  const { priceId } = await req.json()

  const checkoutSession = await stripe.checkout.sessions.create({
    mode: "subscription", // or "payment" for one-time
    payment_method_types: ["card"],
    customer_email: session.user.email!,
    line_items: [
      {
        price: priceId,
        quantity: 1,
      },
    ],
    success_url: `${process.env.NEXT_PUBLIC_APP_URL}/dashboard?success=true`,
    cancel_url: `${process.env.NEXT_PUBLIC_APP_URL}/pricing?canceled=true`,
    metadata: {
      userId: session.user.id,
    },
  })

  return NextResponse.json({ url: checkoutSession.url })
}
```

```tsx
// Client-side checkout button
"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"

export function CheckoutButton({ priceId }: { priceId: string }) {
  const [loading, setLoading] = useState(false)

  async function handleCheckout() {
    setLoading(true)
    try {
      const res = await fetch("/api/checkout", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ priceId }),
      })
      const { url } = await res.json()
      window.location.href = url
    } catch (error) {
      console.error(error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <Button onClick={handleCheckout} disabled={loading}>
      {loading ? "Loading..." : "Subscribe"}
    </Button>
  )
}
```

## Webhook Handler

```tsx
// app/api/webhooks/stripe/route.ts
import { headers } from "next/headers"
import { NextResponse } from "next/server"
import { stripe } from "@/lib/stripe"
import { db } from "@/lib/db"
import Stripe from "stripe"

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
    console.error("Webhook signature verification failed")
    return NextResponse.json({ error: "Invalid signature" }, { status: 400 })
  }

  try {
    switch (event.type) {
      case "checkout.session.completed": {
        const session = event.data.object as Stripe.Checkout.Session
        await handleCheckoutComplete(session)
        break
      }
      case "customer.subscription.created":
      case "customer.subscription.updated": {
        const subscription = event.data.object as Stripe.Subscription
        await handleSubscriptionChange(subscription)
        break
      }
      case "customer.subscription.deleted": {
        const subscription = event.data.object as Stripe.Subscription
        await handleSubscriptionCanceled(subscription)
        break
      }
      case "invoice.payment_succeeded": {
        const invoice = event.data.object as Stripe.Invoice
        await handleInvoicePaid(invoice)
        break
      }
      case "invoice.payment_failed": {
        const invoice = event.data.object as Stripe.Invoice
        await handlePaymentFailed(invoice)
        break
      }
    }
  } catch (error) {
    console.error("Webhook handler error:", error)
    return NextResponse.json({ error: "Webhook handler failed" }, { status: 500 })
  }

  return NextResponse.json({ received: true })
}

async function handleCheckoutComplete(session: Stripe.Checkout.Session) {
  const userId = session.metadata?.userId
  if (!userId) return

  await db.user.update({
    where: { id: userId },
    data: {
      stripeCustomerId: session.customer as string,
      stripeSubscriptionId: session.subscription as string,
    },
  })
}

async function handleSubscriptionChange(subscription: Stripe.Subscription) {
  const customerId = subscription.customer as string

  await db.user.update({
    where: { stripeCustomerId: customerId },
    data: {
      stripeSubscriptionId: subscription.id,
      stripePriceId: subscription.items.data[0].price.id,
      stripeCurrentPeriodEnd: new Date(subscription.current_period_end * 1000),
      subscriptionStatus: subscription.status,
    },
  })
}

async function handleSubscriptionCanceled(subscription: Stripe.Subscription) {
  const customerId = subscription.customer as string

  await db.user.update({
    where: { stripeCustomerId: customerId },
    data: {
      subscriptionStatus: "canceled",
    },
  })
}
```

## Customer Portal

```tsx
// app/api/portal/route.ts
import { NextResponse } from "next/server"
import { stripe } from "@/lib/stripe"
import { auth } from "@/lib/auth"
import { db } from "@/lib/db"

export async function POST() {
  const session = await auth()
  if (!session?.user) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
  }

  const user = await db.user.findUnique({
    where: { id: session.user.id },
  })

  if (!user?.stripeCustomerId) {
    return NextResponse.json({ error: "No customer" }, { status: 400 })
  }

  const portalSession = await stripe.billingPortal.sessions.create({
    customer: user.stripeCustomerId,
    return_url: `${process.env.NEXT_PUBLIC_APP_URL}/dashboard/billing`,
  })

  return NextResponse.json({ url: portalSession.url })
}
```

## Pricing Page Pattern

```tsx
// Pricing tiers data
const plans = [
  {
    name: "Free",
    price: "$0",
    priceId: null,
    features: ["5 projects", "Basic analytics", "Email support"],
  },
  {
    name: "Pro",
    price: "$19",
    priceId: process.env.NEXT_PUBLIC_STRIPE_PRO_PRICE_ID,
    features: ["Unlimited projects", "Advanced analytics", "Priority support"],
    popular: true,
  },
  {
    name: "Enterprise",
    price: "$99",
    priceId: process.env.NEXT_PUBLIC_STRIPE_ENTERPRISE_PRICE_ID,
    features: ["Everything in Pro", "Custom integrations", "Dedicated support"],
  },
]

export function PricingCards() {
  return (
    <div className="grid md:grid-cols-3 gap-8">
      {plans.map((plan) => (
        <Card key={plan.name} className={plan.popular ? "border-primary" : ""}>
          <CardHeader>
            {plan.popular && <Badge>Most Popular</Badge>}
            <CardTitle>{plan.name}</CardTitle>
            <div className="text-3xl font-bold">{plan.price}/mo</div>
          </CardHeader>
          <CardContent>
            <ul className="space-y-2">
              {plan.features.map((feature) => (
                <li key={feature} className="flex items-center gap-2">
                  <Check className="h-4 w-4 text-green-500" />
                  {feature}
                </li>
              ))}
            </ul>
          </CardContent>
          <CardFooter>
            {plan.priceId ? (
              <CheckoutButton priceId={plan.priceId} />
            ) : (
              <Button variant="outline" className="w-full">
                Get Started
              </Button>
            )}
          </CardFooter>
        </Card>
      ))}
    </div>
  )
}
```

## Subscription Helpers

```tsx
// lib/subscription.ts
import { stripe } from "@/lib/stripe"
import { db } from "@/lib/db"

export async function getUserSubscription(userId: string) {
  const user = await db.user.findUnique({
    where: { id: userId },
    select: {
      stripeSubscriptionId: true,
      stripeCurrentPeriodEnd: true,
      stripePriceId: true,
      subscriptionStatus: true,
    },
  })

  if (!user) return null

  const isActive =
    user.subscriptionStatus === "active" ||
    user.subscriptionStatus === "trialing"

  const isValidSubscription =
    isActive && user.stripeCurrentPeriodEnd &&
    user.stripeCurrentPeriodEnd.getTime() > Date.now()

  return {
    ...user,
    isActive,
    isValidSubscription,
    isPro: isValidSubscription && user.stripePriceId === process.env.STRIPE_PRO_PRICE_ID,
    isEnterprise: isValidSubscription && user.stripePriceId === process.env.STRIPE_ENTERPRISE_PRICE_ID,
  }
}

export async function cancelSubscription(subscriptionId: string) {
  return stripe.subscriptions.update(subscriptionId, {
    cancel_at_period_end: true,
  })
}

export async function resumeSubscription(subscriptionId: string) {
  return stripe.subscriptions.update(subscriptionId, {
    cancel_at_period_end: false,
  })
}
```

## Environment Variables

```bash
# .env.local
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...
NEXT_PUBLIC_STRIPE_PRO_PRICE_ID=price_...
NEXT_PUBLIC_STRIPE_ENTERPRISE_PRICE_ID=price_...
```

## Testing Webhooks Locally

```bash
# Install Stripe CLI
brew install stripe/stripe-cli/stripe

# Login
stripe login

# Forward webhooks to local server
stripe listen --forward-to localhost:3000/api/webhooks/stripe

# Trigger test events
stripe trigger checkout.session.completed
stripe trigger customer.subscription.updated
```
