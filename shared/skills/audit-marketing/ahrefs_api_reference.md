# Ahrefs API Reference — Product Marketing Audit Skill

*Tested April 20, 2026 against nostra.ai. All endpoints confirmed working.*

**Base URL:** `https://api.ahrefs.com/v3/`  
**Auth:** Bearer token in Authorization header  
**Key location:** `C:\Users\Ziggy\OneDrive\Desktop\Corey Stuff\claude_code_projects\keys.env` → `AHREFS_API_KEY`

```bash
AHREFS_KEY=$(grep AHREFS_API_KEY /path/to/keys.env | cut -d'=' -f2)
TODAY=$(date +%Y-%m-%d)
```

---

## Common Gotchas (Read First)

- `date` param is **required** on all site-explorer endpoints — use `$(date +%Y-%m-%d)`
- Field names differ between endpoints — do NOT assume they're the same:
  - `keyword_difficulty` works in `organic-keywords` but NOT in `keywords-explorer` (use `difficulty` there)
  - `sum_traffic` is the correct traffic field in `organic-keywords` (not `traffic`)
  - `best_position` is the rank field in `organic-keywords` (not `position`)
  - `keywords` (plural) is the param name in keywords-explorer (not `keyword`)
- `mode=subdomains` should be used on all site-explorer calls to capture full domain traffic
- `select` param is **required** on several endpoints — if you get "missing argument select", add it
- keywords-explorer/matching-terms requires `keywords` param, cannot be empty

---

## Endpoint Reference

### 1. Domain Rating

**Use for:** Getting DR score for client and each competitor.

```bash
curl -s "https://api.ahrefs.com/v3/site-explorer/domain-rating?target={DOMAIN}&date=$TODAY" \
  -H "Authorization: Bearer $AHREFS_KEY"
```

**Response:**
```json
{ "domain_rating": { "domain_rating": 61.0, "ahrefs_rank": 260100 } }
```

**Fields:** `domain_rating` (float 0-100), `ahrefs_rank` (global rank)

---

### 2. Site Metrics Overview

**Use for:** Organic keyword count, organic traffic, paid traffic, paid keyword count for client and competitors. This is the primary endpoint for the competitor comparison table.

```bash
curl -s "https://api.ahrefs.com/v3/site-explorer/metrics?target={DOMAIN}&date=$TODAY&mode=subdomains" \
  -H "Authorization: Bearer $AHREFS_KEY"
```

**Response:**
```json
{
  "metrics": {
    "org_keywords": 335,
    "paid_keywords": 0,
    "org_keywords_1_3": 82,
    "org_traffic": 7659,
    "org_cost": 357641,
    "paid_traffic": 0,
    "paid_cost": null,
    "paid_pages": 0
  }
}
```

**Fields:**
- `org_keywords` — total ranking keywords
- `org_keywords_1_3` — keywords ranking positions 1-3
- `org_traffic` — estimated monthly organic traffic
- `org_cost` — estimated value of organic traffic in USD (cost if paid)
- `paid_traffic` — estimated monthly paid traffic
- `paid_cost` — estimated monthly paid spend in USD

---

### 3. Top Organic Keywords

**Use for:** SEO content section — what is the client actually ranking for, what intent, branded vs non-branded.

```bash
curl -s "https://api.ahrefs.com/v3/site-explorer/organic-keywords?target={DOMAIN}&date=$TODAY&mode=subdomains&limit=25&order_by=sum_traffic%3Adesc&select=keyword,best_position,sum_traffic,volume,keyword_difficulty,best_position_url,is_branded,is_commercial,is_transactional,is_informational" \
  -H "Authorization: Bearer $AHREFS_KEY"
```

**Response:**
```json
{
  "keywords": [
    {
      "keyword": "what is a landing page conversion",
      "best_position": 8,
      "sum_traffic": 5221,
      "volume": 91000,
      "keyword_difficulty": 21,
      "best_position_url": "https://www.nostra.ai/blogs-collection/landing-page-conversion-rate",
      "is_branded": false,
      "is_commercial": false,
      "is_transactional": false,
      "is_informational": true
    }
  ]
}
```

**Fields:**
- `keyword` — the keyword string
- `best_position` — current ranking position
- `sum_traffic` — estimated monthly clicks from this keyword
- `volume` — monthly search volume
- `keyword_difficulty` — difficulty score 0-100
- `best_position_url` — which page on the site ranks
- `is_branded` / `is_commercial` / `is_transactional` / `is_informational` — intent flags

**Notes:** 
- Order by `sum_traffic:desc` to get highest-impact keywords first
- Use intent flags to analyze whether traffic is buyer-intent vs. informational
- Look for branded vs. non-branded split

---

### 4. Backlink Statistics

**Use for:** Backlink profile section in SEO content. Live vs. all-time links, referring domain count.

```bash
curl -s "https://api.ahrefs.com/v3/site-explorer/backlinks-stats?target={DOMAIN}&date=$TODAY&mode=subdomains" \
  -H "Authorization: Bearer $AHREFS_KEY"
```

**Response:**
```json
{
  "metrics": {
    "live": 6229,
    "all_time": 25451,
    "live_refdomains": 663,
    "all_time_refdomains": 2327
  }
}
```

**Fields:**
- `live` — current live backlinks
- `all_time` — all backlinks ever
- `live_refdomains` — unique referring domains (live)
- `all_time_refdomains` — unique referring domains (all time)

---

### 5. Top Pages by Traffic

**Use for:** Identifying traffic concentration risk — which pages drive the most traffic, what their top keywords are.

```bash
curl -s "https://api.ahrefs.com/v3/site-explorer/top-pages?target={DOMAIN}&date=$TODAY&mode=subdomains&limit=10&select=url,sum_traffic,top_keyword,top_keyword_volume&order_by=sum_traffic%3Adesc" \
  -H "Authorization: Bearer $AHREFS_KEY"
```

**Response:**
```json
{
  "pages": [
    {
      "url": "https://www.nostra.ai/blogs-collection/landing-page-conversion-rate",
      "sum_traffic": 5478,
      "top_keyword": "what is a landing page conversion",
      "top_keyword_volume": 91000
    }
  ]
}
```

**Fields:** `url`, `sum_traffic`, `top_keyword`, `top_keyword_volume`

**Note:** Useful for flagging concentration risk (e.g., "one article carries 70% of organic traffic").

---

### 6. Top Referring Domains

**Use for:** Sampling backlink profile quality — what kinds of sites link to the client.

```bash
curl -s "https://api.ahrefs.com/v3/site-explorer/refdomains?target={DOMAIN}&date=$TODAY&mode=subdomains&limit=10&select=domain_rating,domain&order_by=domain_rating%3Adesc" \
  -H "Authorization: Bearer $AHREFS_KEY"
```

**Response:**
```json
{
  "refdomains": [
    { "domain_rating": 92.0, "domain": "techcrunch.com" },
    { "domain_rating": 87.0, "domain": "forbes.com" }
  ]
}
```

**Fields:** `domain` (linking domain), `domain_rating` (their DR)

---

### 7. Keyword Research — Known Keywords

**Use for:** Looking up volume, difficulty, traffic potential for a specific list of keywords. Best when you already know which keywords to check (e.g., based on client's product category).

```bash
curl -s "https://api.ahrefs.com/v3/keywords-explorer/overview?keywords={KW1},{KW2},{KW3}&country=us&select=keyword,volume,difficulty,traffic_potential,cpc,intents" \
  -H "Authorization: Bearer $AHREFS_KEY"
```

**Example:**
```bash
curl -s "https://api.ahrefs.com/v3/keywords-explorer/overview?keywords=shopify+bot+protection,shopify+server+side+tracking,shopify+speed+optimization+services&country=us&select=keyword,volume,difficulty,traffic_potential,cpc,intents" \
  -H "Authorization: Bearer $AHREFS_KEY"
```

**Response:**
```json
{
  "keywords": [
    {
      "keyword": "shopify bot protection",
      "volume": 250,
      "difficulty": 5,
      "traffic_potential": 150,
      "clicks": null,
      "cpc": 600,
      "intents": {
        "informational": true,
        "navigational": false,
        "commercial": false,
        "transactional": false,
        "branded": true,
        "local": false
      }
    }
  ]
}
```

**Fields:**
- `volume` — monthly search volume
- `difficulty` — keyword difficulty 0-100 (use this, NOT `keyword_difficulty`)
- `traffic_potential` — estimated traffic if ranking #1 for full topic cluster
- `cpc` — cost per click in USD cents
- `intents` — object with boolean flags for each intent type

**Note:** `traffic_potential` is often more valuable than `volume` for assessing the full content opportunity. URL-encode spaces as `+` in the keywords param.

---

### 8. Keyword Matching Terms (Related Keywords)

**Use for:** Expanding keyword research — given a seed keyword, find related variations with volume and difficulty. Great for building keyword tables in the SEO section.

```bash
curl -s "https://api.ahrefs.com/v3/keywords-explorer/matching-terms?keywords={SEED_KEYWORD}&country=us&limit=15&select=keyword,volume,difficulty,traffic_potential&order_by=volume%3Adesc" \
  -H "Authorization: Bearer $AHREFS_KEY"
```

**Example:**
```bash
curl -s "https://api.ahrefs.com/v3/keywords-explorer/matching-terms?keywords=shopify+bot+protection&country=us&limit=15&select=keyword,volume,difficulty,traffic_potential&order_by=volume%3Adesc" \
  -H "Authorization: Bearer $AHREFS_KEY"
```

**Response:**
```json
{
  "keywords": [
    { "keyword": "shopify bot protection", "volume": 250, "difficulty": 5, "traffic_potential": 150 },
    { "keyword": "bot protection shopify", "volume": 40, "difficulty": null, "traffic_potential": null },
    { "keyword": "best bot protection app for shopify", "volume": 10, "difficulty": null, "traffic_potential": null }
  ]
}
```

**Note:** `difficulty` and `traffic_potential` may be null for low-volume keywords. That's fine — still useful to show the keyword cluster.

---

## Standard Audit Workflow — API Call Sequence

For each audit, run these calls in order. Replace `{DOMAIN}` with the client's domain (e.g., `nostra.ai`, no `https://`).

### Phase A: Client Domain Profile

```bash
TODAY=$(date +%Y-%m-%d)
DOMAIN="client-domain.com"

# 1. Domain Rating
curl -s "https://api.ahrefs.com/v3/site-explorer/domain-rating?target=$DOMAIN&date=$TODAY" \
  -H "Authorization: Bearer $AHREFS_KEY"

# 2. Traffic & Keyword Overview
curl -s "https://api.ahrefs.com/v3/site-explorer/metrics?target=$DOMAIN&date=$TODAY&mode=subdomains" \
  -H "Authorization: Bearer $AHREFS_KEY"

# 3. Top 25 Keywords (sorted by traffic)
curl -s "https://api.ahrefs.com/v3/site-explorer/organic-keywords?target=$DOMAIN&date=$TODAY&mode=subdomains&limit=25&order_by=sum_traffic%3Adesc&select=keyword,best_position,sum_traffic,volume,keyword_difficulty,best_position_url,is_branded,is_commercial,is_transactional,is_informational" \
  -H "Authorization: Bearer $AHREFS_KEY"

# 4. Backlink Stats
curl -s "https://api.ahrefs.com/v3/site-explorer/backlinks-stats?target=$DOMAIN&date=$TODAY&mode=subdomains" \
  -H "Authorization: Bearer $AHREFS_KEY"

# 5. Top Pages (traffic concentration)
curl -s "https://api.ahrefs.com/v3/site-explorer/top-pages?target=$DOMAIN&date=$TODAY&mode=subdomains&limit=10&select=url,sum_traffic,top_keyword,top_keyword_volume&order_by=sum_traffic%3Adesc" \
  -H "Authorization: Bearer $AHREFS_KEY"
```

### Phase B: Competitor Comparison Table

Loop through each competitor domain. For each one, get DR + metrics:

```bash
for COMP in competitor1.com competitor2.com competitor3.com; do
  echo "=== $COMP ==="
  DR=$(curl -s "https://api.ahrefs.com/v3/site-explorer/domain-rating?target=$COMP&date=$TODAY" \
    -H "Authorization: Bearer $AHREFS_KEY")
  METRICS=$(curl -s "https://api.ahrefs.com/v3/site-explorer/metrics?target=$COMP&date=$TODAY&mode=subdomains" \
    -H "Authorization: Bearer $AHREFS_KEY")
  echo "DR: $DR"
  echo "Metrics: $METRICS"
done
```

Build the competitor table from this data:
| Domain | DR | Org Keywords | Org Traffic | Paid Traffic |
|---|---|---|---|---|

### Phase C: Keyword Research (SEO Section)

Two steps:
1. Use `keywords-explorer/overview` to look up specific candidate keywords relevant to the client's products
2. Use `keywords-explorer/matching-terms` to expand each product category into a full keyword cluster

**For keyword selection:** Claude should derive seed keywords from the client's product/feature names and their likely buyer searches. For a B2B SaaS with 3 products, generate ~5-10 candidate keywords per product, look them all up, then expand with matching-terms for the best ones.

---

## Output: Competitor Table Format

Use this Markdown table format in the final audit output (matches the example Nostra output):

```markdown
| Domain | DR | Org Keywords | Org Traffic | Paid Traffic |
| --- | --- | --- | --- | --- |
| client.com | 61 | 335 | 7,659 | $0 |
| competitor1.com | 52 | 141 | 285 | $0 |
| competitor2.com | 71 | 320 | 402 | $0 |
```

## Output: Keyword Research Table Format

```markdown
| Keyword | Volume | KD | Traffic Potential |
| --- | --- | --- | --- |
| shopify bot protection | 250 | 5 | 150 |
| bot protection shopify | 40 | — | — |
| best bot protection app for shopify | 10 | — | — |
```

Use `—` for null KD or traffic potential values.

---

## Fallback: When Ahrefs Quota Is Exhausted

Check `keys.env` for open source SEO API keys. Note in the audit output that data came from a secondary source. The field names and endpoints will differ — consult that API's docs.

---

*Last updated: April 20, 2026*
