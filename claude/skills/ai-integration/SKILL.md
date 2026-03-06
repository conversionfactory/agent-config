---
name: ai-integration
description: AI SDK patterns for Anthropic Claude and OpenAI. Use when adding AI features to apps, streaming responses, tool use, or building chat interfaces.
---

# AI Integration Skill

## Vercel AI SDK (Recommended)

The easiest way to add AI to Next.js apps with streaming support.

```bash
npm install ai @ai-sdk/anthropic @ai-sdk/openai
```

### Basic Chat Route

```typescript
// app/api/chat/route.ts
import { anthropic } from "@ai-sdk/anthropic"
import { streamText } from "ai"

export async function POST(req: Request) {
  const { messages } = await req.json()

  const result = streamText({
    model: anthropic("claude-sonnet-4-20250514"),
    system: "You are a helpful assistant.",
    messages,
  })

  return result.toDataStreamResponse()
}
```

### Client-Side Chat

```tsx
"use client"

import { useChat } from "ai/react"

export function Chat() {
  const { messages, input, handleInputChange, handleSubmit, isLoading } =
    useChat({
      api: "/api/chat",
    })

  return (
    <div className="flex flex-col h-screen">
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.map((m) => (
          <div
            key={m.id}
            className={m.role === "user" ? "text-right" : "text-left"}
          >
            <span
              className={`inline-block p-3 rounded-lg ${
                m.role === "user"
                  ? "bg-blue-500 text-white"
                  : "bg-gray-200"
              }`}
            >
              {m.content}
            </span>
          </div>
        ))}
      </div>
      <form onSubmit={handleSubmit} className="p-4 border-t">
        <input
          value={input}
          onChange={handleInputChange}
          placeholder="Type a message..."
          className="w-full p-2 border rounded"
          disabled={isLoading}
        />
      </form>
    </div>
  )
}
```

### Tool Use / Function Calling

```typescript
// app/api/chat/route.ts
import { anthropic } from "@ai-sdk/anthropic"
import { streamText, tool } from "ai"
import { z } from "zod"

export async function POST(req: Request) {
  const { messages } = await req.json()

  const result = streamText({
    model: anthropic("claude-sonnet-4-20250514"),
    messages,
    tools: {
      getWeather: tool({
        description: "Get the current weather for a location",
        parameters: z.object({
          location: z.string().describe("City name"),
        }),
        execute: async ({ location }) => {
          // Call weather API
          const weather = await fetchWeather(location)
          return weather
        },
      }),
      searchProducts: tool({
        description: "Search for products in the catalog",
        parameters: z.object({
          query: z.string(),
          maxResults: z.number().default(5),
        }),
        execute: async ({ query, maxResults }) => {
          const products = await db.product.findMany({
            where: { name: { contains: query, mode: "insensitive" } },
            take: maxResults,
          })
          return products
        },
      }),
    },
  })

  return result.toDataStreamResponse()
}
```

### Generate Object (Structured Output)

```typescript
import { anthropic } from "@ai-sdk/anthropic"
import { generateObject } from "ai"
import { z } from "zod"

const ProductSchema = z.object({
  name: z.string(),
  description: z.string(),
  features: z.array(z.string()),
  price: z.number(),
})

export async function generateProductDescription(rawData: string) {
  const { object } = await generateObject({
    model: anthropic("claude-sonnet-4-20250514"),
    schema: ProductSchema,
    prompt: `Extract product information from: ${rawData}`,
  })

  return object // Typed as { name, description, features, price }
}
```

### Streaming UI Components

```tsx
"use client"

import { useChat } from "ai/react"
import { useEffect, useRef } from "react"

export function ChatWithStreaming() {
  const { messages, input, handleInputChange, handleSubmit, isLoading } =
    useChat()
  const messagesEndRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" })
  }, [messages])

  return (
    <div className="flex flex-col h-[600px]">
      <div className="flex-1 overflow-y-auto p-4">
        {messages.map((m) => (
          <div key={m.id} className="mb-4">
            <strong>{m.role === "user" ? "You" : "AI"}:</strong>
            <p className="whitespace-pre-wrap">{m.content}</p>
          </div>
        ))}
        {isLoading && (
          <div className="animate-pulse text-gray-500">AI is typing...</div>
        )}
        <div ref={messagesEndRef} />
      </div>
      <form onSubmit={handleSubmit} className="p-4 border-t flex gap-2">
        <input
          value={input}
          onChange={handleInputChange}
          className="flex-1 p-2 border rounded"
          placeholder="Ask anything..."
        />
        <button
          type="submit"
          disabled={isLoading}
          className="px-4 py-2 bg-blue-500 text-white rounded disabled:opacity-50"
        >
          Send
        </button>
      </form>
    </div>
  )
}
```

---

## Anthropic SDK Direct

For more control or non-Next.js apps.

```bash
npm install @anthropic-ai/sdk
```

### Basic Completion

```typescript
import Anthropic from "@anthropic-ai/sdk"

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
})

async function chat(userMessage: string) {
  const response = await anthropic.messages.create({
    model: "claude-sonnet-4-20250514",
    max_tokens: 1024,
    messages: [{ role: "user", content: userMessage }],
  })

  return response.content[0].type === "text"
    ? response.content[0].text
    : null
}
```

### Streaming

```typescript
async function streamChat(userMessage: string) {
  const stream = await anthropic.messages.stream({
    model: "claude-sonnet-4-20250514",
    max_tokens: 1024,
    messages: [{ role: "user", content: userMessage }],
  })

  for await (const event of stream) {
    if (
      event.type === "content_block_delta" &&
      event.delta.type === "text_delta"
    ) {
      process.stdout.write(event.delta.text)
    }
  }

  const finalMessage = await stream.finalMessage()
  return finalMessage
}
```

### Tool Use

```typescript
const response = await anthropic.messages.create({
  model: "claude-sonnet-4-20250514",
  max_tokens: 1024,
  tools: [
    {
      name: "get_weather",
      description: "Get current weather for a location",
      input_schema: {
        type: "object",
        properties: {
          location: { type: "string", description: "City name" },
        },
        required: ["location"],
      },
    },
  ],
  messages: [{ role: "user", content: "What's the weather in Tokyo?" }],
})

// Handle tool use
for (const block of response.content) {
  if (block.type === "tool_use") {
    const toolResult = await executeToolCall(block.name, block.input)

    // Continue conversation with tool result
    const followUp = await anthropic.messages.create({
      model: "claude-sonnet-4-20250514",
      max_tokens: 1024,
      tools: [...],
      messages: [
        { role: "user", content: "What's the weather in Tokyo?" },
        { role: "assistant", content: response.content },
        {
          role: "user",
          content: [
            {
              type: "tool_result",
              tool_use_id: block.id,
              content: JSON.stringify(toolResult),
            },
          ],
        },
      ],
    })
  }
}
```

---

## OpenAI SDK

```bash
npm install openai
```

```typescript
import OpenAI from "openai"

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
})

// Chat completion
const response = await openai.chat.completions.create({
  model: "gpt-4o",
  messages: [
    { role: "system", content: "You are a helpful assistant." },
    { role: "user", content: "Hello!" },
  ],
})

// Streaming
const stream = await openai.chat.completions.create({
  model: "gpt-4o",
  messages: [...],
  stream: true,
})

for await (const chunk of stream) {
  const content = chunk.choices[0]?.delta?.content || ""
  process.stdout.write(content)
}
```

---

## Common Patterns

### Rate Limiting

```typescript
import { Ratelimit } from "@upstash/ratelimit"
import { Redis } from "@upstash/redis"

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, "1 m"), // 10 requests per minute
})

export async function POST(req: Request) {
  const ip = req.headers.get("x-forwarded-for") ?? "anonymous"
  const { success } = await ratelimit.limit(ip)

  if (!success) {
    return Response.json({ error: "Rate limited" }, { status: 429 })
  }

  // Continue with AI call...
}
```

### Caching Responses

```typescript
import { kv } from "@vercel/kv"

async function getCachedOrGenerate(prompt: string) {
  const cacheKey = `ai:${hashPrompt(prompt)}`

  // Check cache
  const cached = await kv.get(cacheKey)
  if (cached) return cached

  // Generate
  const result = await generateText({ ... })

  // Cache for 1 hour
  await kv.set(cacheKey, result, { ex: 3600 })

  return result
}
```

### Error Handling

```typescript
try {
  const result = await generateText({ ... })
} catch (error) {
  if (error instanceof Anthropic.APIError) {
    if (error.status === 429) {
      // Rate limited - retry with backoff
    } else if (error.status === 500) {
      // Server error - retry
    }
  }
  throw error
}
```

### Token Counting (Approximate)

```typescript
// Rough estimate: ~4 characters per token
function estimateTokens(text: string): number {
  return Math.ceil(text.length / 4)
}

// Check before sending
const estimatedTokens = estimateTokens(prompt)
if (estimatedTokens > 100000) {
  throw new Error("Prompt too long")
}
```

### Model Selection

| Model | Use Case | Cost |
|-------|----------|------|
| `claude-sonnet-4-20250514` | Best balance of speed/quality | Medium |
| `claude-opus-4-20250514` | Complex reasoning, long context | High |
| `claude-haiku-3-5-20241022` | Fast, simple tasks | Low |
| `gpt-4o` | General purpose, vision | Medium |
| `gpt-4o-mini` | Fast, cheap | Low |
