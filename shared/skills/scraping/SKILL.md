---
name: scraping
description: Web scraping and data extraction. Use when building scrapers, extracting data from websites, parsing HTML, or automating web data collection.
---

# Web Scraping Skill

## Tools by Use Case

| Use Case | Tool | Why |
|----------|------|-----|
| Simple HTML | Cheerio | Fast, jQuery-like, no browser |
| JavaScript-rendered | Playwright/Puppeteer | Full browser, handles SPAs |
| API-based | Fetch + parsing | Fastest, most reliable |
| Large scale | Crawlee | Queue management, retries |

## Cheerio (Node.js - Static HTML)

```bash
npm install cheerio
```

```typescript
import * as cheerio from "cheerio"

async function scrapeProducts(url: string) {
  const response = await fetch(url)
  const html = await response.text()
  const $ = cheerio.load(html)

  const products: Product[] = []

  $(".product-card").each((_, element) => {
    products.push({
      title: $(element).find(".title").text().trim(),
      price: $(element).find(".price").text().trim(),
      image: $(element).find("img").attr("src"),
      link: $(element).find("a").attr("href"),
    })
  })

  return products
}
```

## Playwright (JavaScript-rendered)

```bash
npm install playwright
npx playwright install chromium
```

```typescript
import { chromium, type Page } from "playwright"

async function scrapeWithPlaywright(url: string) {
  const browser = await chromium.launch({ headless: true })
  const page = await browser.newPage()

  try {
    await page.goto(url, { waitUntil: "networkidle" })

    // Wait for content to load
    await page.waitForSelector(".product-list")

    // Extract data
    const products = await page.$$eval(".product-card", (cards) =>
      cards.map((card) => ({
        title: card.querySelector(".title")?.textContent?.trim(),
        price: card.querySelector(".price")?.textContent?.trim(),
      }))
    )

    return products
  } finally {
    await browser.close()
  }
}

// With interactions
async function scrapeWithPagination(url: string) {
  const browser = await chromium.launch()
  const page = await browser.newPage()
  const allProducts: Product[] = []

  await page.goto(url)

  while (true) {
    // Scrape current page
    const products = await extractProducts(page)
    allProducts.push(...products)

    // Check for next button
    const nextButton = await page.$("button.next:not([disabled])")
    if (!nextButton) break

    await nextButton.click()
    await page.waitForLoadState("networkidle")
  }

  await browser.close()
  return allProducts
}
```

## Handling Anti-Scraping

```typescript
// Random delays
function randomDelay(min = 1000, max = 3000) {
  return new Promise((resolve) =>
    setTimeout(resolve, Math.random() * (max - min) + min)
  )
}

// Rotate user agents
const userAgents = [
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36...",
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36...",
]

async function fetchWithHeaders(url: string) {
  const response = await fetch(url, {
    headers: {
      "User-Agent": userAgents[Math.floor(Math.random() * userAgents.length)],
      Accept: "text/html,application/xhtml+xml",
      "Accept-Language": "en-US,en;q=0.9",
    },
  })
  return response
}

// With Playwright
const context = await browser.newContext({
  userAgent: userAgents[0],
  viewport: { width: 1920, height: 1080 },
  locale: "en-US",
})
```

## API-First Approach (Preferred)

```typescript
// Check for APIs in Network tab first!
async function scrapeViaApi(searchTerm: string) {
  // Many sites have internal APIs that return JSON
  const response = await fetch(
    `https://example.com/api/search?q=${encodeURIComponent(searchTerm)}`,
    {
      headers: {
        Accept: "application/json",
        // Copy headers from browser Network tab
      },
    }
  )

  const data = await response.json()
  return data.results
}
```

## Next.js API Route Scraper

```typescript
// app/api/scrape/route.ts
import { NextResponse } from "next/server"
import * as cheerio from "cheerio"

export async function POST(req: Request) {
  const { url } = await req.json()

  try {
    const response = await fetch(url, {
      headers: {
        "User-Agent": "Mozilla/5.0 (compatible; MyBot/1.0)",
      },
    })

    if (!response.ok) {
      return NextResponse.json(
        { error: `Failed to fetch: ${response.status}` },
        { status: 400 }
      )
    }

    const html = await response.text()
    const $ = cheerio.load(html)

    // Extract metadata
    const data = {
      title: $("title").text(),
      description: $('meta[name="description"]').attr("content"),
      ogImage: $('meta[property="og:image"]').attr("content"),
      // Custom extraction...
    }

    return NextResponse.json(data)
  } catch (error) {
    return NextResponse.json(
      { error: "Scraping failed" },
      { status: 500 }
    )
  }
}
```

## Background Job Scraping (Rails)

```ruby
# app/jobs/scrape_job.rb
class ScrapeJob < ApplicationJob
  queue_as :scraping
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(url, resource_id)
    response = HTTParty.get(url, headers: { "User-Agent" => random_user_agent })
    doc = Nokogiri::HTML(response.body)

    data = {
      title: doc.css("h1").first&.text&.strip,
      price: doc.css(".price").first&.text&.strip,
      # ...
    }

    Resource.find(resource_id).update!(scraped_data: data, scraped_at: Time.current)
  end

  private

  def random_user_agent
    [
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)...",
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64)...",
    ].sample
  end
end
```

## Common Selectors

```typescript
// CSS Selectors
$(".class")              // By class
$("#id")                 // By ID
$("div.class")           // Element with class
$("a[href]")             // Attribute exists
$("a[href^='https']")    // Attribute starts with
$("a[href$='.pdf']")     // Attribute ends with
$("a[href*='product']")  // Attribute contains
$("ul > li")             // Direct children
$("ul li")               // All descendants
$("h2 + p")              // Adjacent sibling
$("tr:nth-child(2)")     // Position-based
$("tr:first-child")      // First element
$("tr:last-child")       // Last element

// Cheerio-specific
$(".item").first()       // First match
$(".item").last()        // Last match
$(".item").eq(2)         // Index-based (0-indexed)
$(".item").filter(fn)    // Filter with function
$(".item").map(fn)       // Map to array
$(".item").text()        // Text content
$(".item").html()        // Inner HTML
$(".item").attr("href")  // Attribute value
$(".item").data("id")    // data-* attribute
```

## Error Handling & Retries

```typescript
async function scrapeWithRetry(
  url: string,
  maxRetries = 3,
  delayMs = 1000
): Promise<string> {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const response = await fetch(url)

      if (response.status === 429) {
        // Rate limited - wait longer
        await new Promise((r) => setTimeout(r, delayMs * attempt * 2))
        continue
      }

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`)
      }

      return await response.text()
    } catch (error) {
      if (attempt === maxRetries) throw error
      await new Promise((r) => setTimeout(r, delayMs * attempt))
    }
  }
  throw new Error("Max retries reached")
}
```

## Storing Scraped Data

```typescript
// Prisma schema for scraped data
model ScrapedItem {
  id        String   @id @default(cuid())
  url       String   @unique
  data      Json
  scrapedAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([scrapedAt])
}

// Upsert pattern
await db.scrapedItem.upsert({
  where: { url },
  create: { url, data: scrapedData },
  update: { data: scrapedData },
})
```

## Ethics & Best Practices

1. **Check robots.txt** - Respect site rules
2. **Rate limit** - Don't overwhelm servers (1-2 req/sec max)
3. **Cache results** - Don't re-scrape unnecessarily
4. **Use APIs when available** - More reliable, often allowed
5. **Identify your bot** - Use descriptive User-Agent
6. **Handle errors gracefully** - Sites change, expect failures
