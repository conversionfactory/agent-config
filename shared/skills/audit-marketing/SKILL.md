---
name: audit-marketing
description: "CF Product Marketing Audit — marketing team portion. Runs automated research, builds a URL inventory, walks the auditor through 17 scored marketing sections, and outputs a Notion-ready document. Use when running the marketing slice of a client product marketing audit. Pass the client domain as an argument, e.g. /audit-marketing nostra.ai"
---

## Setup (do this once before using the skill)

This is Conversion Factory's product marketing audit skill. Before running it the first time, you need two things in place.

### 1. Create your audit config file

Create `~/.claude/audit-config.env` (in your home directory, inside the `.claude/` folder) with these values, edited for your setup:

```bash
# Where audit folders live for each client (one folder per audit)
AUDIT_BASE_DIR="$HOME/audits"

# Ahrefs API key (used during research and FINALIZE for SEO + competitor data)
AHREFS_API_KEY="your_ahrefs_key_here"

# Path to the Ahrefs API reference doc (shipped in this skill's repo as ahrefs_api_reference.md)
AHREFS_API_REFERENCE_PATH="/path/to/ahrefs_api_reference.md"

# Path to finished example audits used as a tone reference during FINALIZE
AUDIT_EXAMPLES_PATH="/path/to/example/audits"
```

If the file is missing, the skill still runs but Ahrefs steps will fail and tone reference falls back to the rules in this doc.

### 2. Understand the two roles in this workflow

This skill is written for two distinct people, not one. Even if you're doing both jobs, the notes are structured to support a hand-off.

- **The auditor** — the person running `/audit-marketing`. Gathers research, walks the skill through section-by-section scoring, edits the final notes. The skill addresses the auditor as "you."
- **The audit presenter** — the senior who reads the notes on camera to record the client-facing Loom. At CF this is typically Corey Haines (head of marketing). The notes are written in second person to the *client* but in a register the presenter can pick up and riff on live — skimmable bullets, not a script.

### 3. Where this skill fits in CF's broader audit workflow

1. Client fills out the preliminary info checklist (competitor list, positioning doc, sales decks, analytics access, free product account, ad library, pricing history, etc.)
2. Auditor drops everything into `{AUDIT_BASE_DIR}/{slug}/materials/` and runs `/audit-marketing {client-domain}`
3. **INIT phase** — skill pulls the website, runs Ahrefs, checks social presence, builds the URL inventory, screenshots key pages, reads materials, writes `research_data.md`
4. **REVIEW phase** — skill walks the auditor through all 17 scored sections in chat; each section is confirmed before being written to `final_output.md`
5. Auditor optionally records their own Loom walking the client's site during/after review
6. **FINALIZE phase** — keyword research runs, Loom transcript (if any) is integrated, the file is verified end-to-end, final output printed
7. Auditor pastes `final_output.md` into Notion
8. Presenter reads the Notion page and records a 5–15 min Loom for the client

The design team (Branding & Visual Design, Web Design) and web dev team (Web Technical) score their own sections separately — those don't appear in this skill's output.

---

## Runtime Context

### Audit State Detection
!`CONFIG="$HOME/.claude/audit-config.env"; [ -f "$CONFIG" ] && source "$CONFIG"; DOMAIN="$1"; SLUG=$(echo "$DOMAIN" | sed 's/[^a-zA-Z0-9]/-/g' | tr '[:upper:]' '[:lower:]'); BASE="${AUDIT_BASE_DIR:-$HOME/audits}"; DIR="$BASE/$SLUG"; if [ -z "$DOMAIN" ]; then echo "ERROR: No domain provided. Usage: /audit-marketing <client-domain>"; elif [ -d "$DIR" ]; then echo "MODE: REVIEW"; echo "AUDIT_DIR: $DIR"; echo "---"; echo "Files in audit folder:"; ls "$DIR"; if [ -f "$DIR/final_output.md" ]; then echo "---"; echo "Progress:"; head -1 "$DIR/final_output.md"; fi; else echo "MODE: INIT"; echo "AUDIT_DIR (to create): $DIR"; fi`

### API Key
!`CONFIG="$HOME/.claude/audit-config.env"; [ -f "$CONFIG" ] && source "$CONFIG"; echo "${AHREFS_API_KEY:-NOT_SET}"`

### Ahrefs API Reference
!`CONFIG="$HOME/.claude/audit-config.env"; [ -f "$CONFIG" ] && source "$CONFIG"; if [ -n "$AHREFS_API_REFERENCE_PATH" ] && [ -f "$AHREFS_API_REFERENCE_PATH" ]; then cat "$AHREFS_API_REFERENCE_PATH"; else echo "Note: AHREFS_API_REFERENCE_PATH not set in ~/.claude/audit-config.env or file not found. Ahrefs steps will need to construct API calls from the docs at https://api.ahrefs.com."; fi`

---

## How to Use This Skill

**Run it:** `/audit-marketing client-domain.com` (e.g. `/audit-marketing nostra.ai`)

**Three phases — the skill detects which one to run automatically:**

| Phase | When it runs | What it does |
|---|---|---|
| INIT | First time running for a new client | Creates the audit folder, fetches the website, pulls SEO data, checks social presence, reads any materials you've dropped in, writes a research file |
| REVIEW | Folder exists, audit in progress | Walks through all 17 sections with you one at a time — you confirm, correct, or add notes before each section is locked in |
| FINALIZE | After all 17 sections are confirmed | Runs keyword research, fills in competitor SEO data, integrates any Loom transcript you provide, prints the finished output ready to paste into Notion |

**Before starting INIT:**
- Drop any client-provided files (positioning doc, competitor list, sales decks, testimonials, email examples) into `audits/{slug}/materials/` — the more you drop in before research starts, the better the output
- If you don't have materials yet, just say "go" — you can drop files in at any time and they'll be picked up when REVIEW starts

**During REVIEW:**
- Each section is shown in chat for your approval before anything is written to the file
- You can correct scores, add notes, or say "next" to move on
- The output file only grows — nothing is overwritten once confirmed

**To finish:**
- After all 17 sections, say "finalize" (or paste a Loom transcript if you recorded a site walkthrough)

---

## Scoring Key

Every rubric item is scored 0–5. Use these anchors consistently:

| Score | Meaning |
|---|---|
| 0/5 | Not present |
| 1/5 | Present but very lacking, insufficient, or counterproductive |
| 2/5 | Present but only barely effective |
| 3/5 | Present, basically effective, but could definitely be improved |
| 4/5 | Exceptional — may benefit from slight tweaks |
| 5/5 | Above and beyond, excellent — leave it alone, call it out as a win |

### Scoring Rules

These rules keep scoring consistent across auditors:

- **Score 0 when a named section is absent.** When a rubric item names a specific section (Manifesto, FAQ, How It Works, Pricing-as-section, Integrations-as-section), score 0/5 if that section doesn't exist on the page. Don't give 1/5 because a related sentence appears somewhere else on the page.
  - **Why:** A stray sentence scattered in unrelated copy isn't the same as a built, intentional section. Giving 1 point for "well, there's a sentence about it in the differentiator block" inflates the score and misrepresents what's actually shipped.
  - **How to apply:** For named-section items, the question is binary — "Is there a section dedicated to this?" If no → 0/5. If yes but weak → 1–2. Trace mentions in unrelated sections are worth noting in the prose, not worth a point.

- **Ask before locking in any 0.** If there's any chance the client has the thing offline or internally (unlisted page, internal doc, offline process), flag it to the auditor first: "I didn't find [X] — do they have this?" Only score 0 after confirmation.

- **Scores are starting points.** The auditor adjusts anything wrong during REVIEW; the Notion rubric is the source of truth for the final number, not the draft.

---

## The Rubric — Audit Sections

These are the 17 sections you score. Use the 0–5 scale above. Missing = 0, but ask the auditor before assigning 0 if there's any chance it exists offline or internally — see PHASE 2 rules.

### 1. Positioning (max 25 pts — 5 items × 5)

> **Framing note:** Positioning is foundational — the strategic anchor everything else builds on. It's iterative (rarely nailed the first try) and should be revisited every 6–12 months. When the client lacks a single source-of-truth doc, that's the standing recommendation.

| Item | Description |
|---|---|
| Information Recency | Positioning doc updated within the last 6 months |
| Defined ICP(s) | Core demographics, firmographics, technographics defined |
| Defined Differentiators | Unique attributes vs competitors clearly outlined |
| JTBD Switch Analysis | Four-forces model: push, pull, anxieties, habits |
| Internal Document | One doc that all key stakeholders agree on |

### 2. Customer Research (max 20 pts — 4 items × 5)

> **Framing note:** Treat customer research as a hierarchy: (1) video calls = richest qualitative interviews (jobs-to-be-done style); (2) surveys = quantitative sample data; (3) reading reviews and forum threads = unbiased but mixed bag, can be misleading. Order suggestions in that priority. Don't default to specific call-recording tools — recommend based on the client's existing stack.

| Item | Description |
|---|---|
| Information Recency | Research updated within 6 months |
| Video Calls | 1:1 calls, demos, or support capturing user insights |
| Surveys | Polls, feedback forms, quizzes capturing visitor insights |
| Online Sleuthing | Reading Reddit threads, Facebook groups, review sites (G2, Trustpilot, App Store), and comment sections to capture the exact words customers use to describe their problems and frustrations — without asking them directly |

### 3. Landing / Home Page (max 65 pts — 13 items × 5)

> 📸 **Before scoring this section:** Take a full-page screenshot and a hero-only screenshot of the homepage. Read the screenshots before writing findings — they reveal layout, above-the-fold content, and visual hierarchy that HTML alone misses.
> ```bash
> npx --yes playwright screenshot --browser chromium --full-page "https://{domain}/" "audits/{slug}/screenshots/homepage-full.png"
> npx --yes playwright screenshot --browser chromium --viewport-size "1440,900" "https://{domain}/" "audits/{slug}/screenshots/homepage-hero.png"
> ```

> **Framing note:** The homepage is the single most important marketing asset — 70%+ of visitors only see this page. Patterns to surface when relevant: subheadlines often work better than headlines; "all-in-one" claims need to immediately show what's included; longer homepages typically convert better; standardize to one primary + one secondary CTA; manifesto/founder letter section is emotional and conversational; before/after section primes skeptical readers; how-it-works section alleviates information overload.

| Item | Description |
|---|---|
| Hero Section | Jargon-free header/subheader, clear value, objection handling, risk reversal |
| Social Proof | At least one form — testimonials or logo pool |
| Before/After | ICP problems mapped to product benefits |
| How It Works | 3–4 steps showing how easy setup is |
| Highlighted Features | Feature explanations in plain English, no jargon |
| Highlighted Integrations | What integrations enable, with impressive facts |
| Pricing | Clear, compounding pricing tiers |
| CTA Section | Final CTA reiterating objection busters and risk reversal |
| Manifesto Section | Founder passion, reinforced value prop, ICP sympathy |
| FAQs | Brief, readable answers to common questions/objections |
| Consistent Primary CTA | Same CTA language/style used throughout the page |
| Message Prioritization | Most important value above the fold |
| Clarity vs. Depth | Copy is persuasive but not too dense to scan |

### 4. Sales Pages (max 10 pts — 2 items × 5)

> 📋 **Page-count verification required.** Before scoring, pull every feature/product/solutions page from the URL inventory in `research_data.md` (sitemap + nav + footer extraction). Solutions pages often live at flat URLs (e.g. `/private-equity` rather than `/solutions/private-equity`) — cross-check against the nav-grouping inventory, not just URL patterns. Present what you find to the auditor and wait for confirmation or additions before locking in a score.

> 📸 **Before scoring this section:** Screenshot the top 2–3 product/feature/solution pages identified during INIT. Look at how content is laid out, whether benefit framing is visible above the fold, and whether CTAs are present.
> ```bash
> npx --yes playwright screenshot --browser chromium --full-page "https://{domain}/{feature-page}" "audits/{slug}/screenshots/sales-page-1.png"
> ```

| Item | Description |
|---|---|
| Feature Pages | In-depth feature explanations in plain English; what the feature enables |
| Solutions Pages | Use case / industry / persona pages with tailored copy and integrations |

### 5. Conversion Pages (max 15 pts — 3 items × 5)

> 📸 **Before scoring this section:** Screenshot the pricing page, demo/contact form, and signup page if they exist. Pay attention to form length, trust signals near the form, and whether the value prop is reinforced at the point of conversion.
> ```bash
> npx --yes playwright screenshot --browser chromium --full-page "https://{domain}/pricing" "audits/{slug}/screenshots/pricing.png"
> npx --yes playwright screenshot --browser chromium --full-page "https://{domain}/demo" "audits/{slug}/screenshots/demo-form.png"
> ```

| Item | Description |
|---|---|
| Pricing Page | Clear, compounding pricing tiers; configurable if necessary |
| Demo Page | Multistep form ensuring SQLs only get access |
| Sign Up Page | Minimal friction, social proof, value reinforcement |

### 6. Competitor Comparison Pages (max 15 pts — 3 items × 5)

> 📋 **Page-count verification required.** Before scoring, check the URL inventory in `research_data.md` for `/vs/*`, `/alternatives/*`, `/compare/*`, `/versus/*` patterns. Present what you find to the auditor and wait for confirmation or additions before locking in a score.

> **Framing note:** Standing framing: clients hesitate on these pages (legal worries, "don't poke the bear"), but buyers are already searching for "[competitor] vs" and "[competitor] alternative" — and AI agents need this content to cite. The concept to lean on is "control the narrative." Four standard formats: you vs competitor, competitor vs competitor, alternative (singular), alternatives (plural). When migration is the client's growth motion, also recommend a migrate-from offer page (CF has used a SavvyCal-style contract buyout playbook for this).

| Item | Description |
|---|---|
| [You] vs [Competitor] | Honest comparison showing why your brand wins |
| [Competitor] vs [Competitor] | Third-party comparison driving traffic to your site |
| [Competitor] Alternative | "Alternative to X" page capturing active evaluation traffic |

### 7. Resources (max 25 pts — 5 items × 5)

> 📋 **Page-count verification required.** Before scoring, pull every blog/case-study/webinar/podcast/resource URL from the inventory. Resource hubs often live under non-obvious paths (`/learn`, `/library`, `/guides`) — check nav + footer groupings, not just URL patterns. Present what you find to the auditor and wait for confirmation before locking in a score.

> 📸 **Before scoring this section:** Screenshot the blog index page and one or two individual posts/articles. This reveals whether posts are actually HTML or PDF, whether CTAs exist, what the content experience looks like, and how the hub is organized.
> ```bash
> npx --yes playwright screenshot --browser chromium --full-page "https://{domain}/blog" "audits/{slug}/screenshots/blog-index.png"
> # Screenshot an individual post if one exists
> npx --yes playwright screenshot --browser chromium --full-page "https://{domain}/blog/{first-post}" "audits/{slug}/screenshots/blog-post-example.png"
> ```

| Item | Description |
|---|---|
| Blog | Content hub with keyword placement, SEO-friendly structure |
| Case Studies | Dedicated pages with results-driven success stories |
| Podcasts | Thought leadership audio hub |
| Webinars | Live/on-demand expert sessions page or hub |
| Extra Resources | YouTube, templates, guides, ebooks, downloadable assets |

### 8. Onboarding (max 15 pts — 3 items × 5)
| Item | Description |
|---|---|
| Tooltips, Checklists, Guides | In-app guidance from start to value (Pendo, Userlist, etc.) |
| "First Run" Screens | In-app A/B testable onboarding flows for new users |
| Mitigated Sign-Up Friction | Unnecessary steps removed, reduced time-to-value |

### 9. Email Marketing (max 25 pts — 5 items × 5)

> **Framing note:** Standing theme — owned channels beat rented attention. If the client is paying for newsletter ad placements (industry newsletters, sponsored content), reframe that as "you're paying to rent an audience you could own." Check for the same five sequence types every audit: broadcasts, free→paid, behavior-triggered, re-engagement, lead nurturing.

| Item | Description |
|---|---|
| General Broadcasts | Weekly/monthly/quarterly emails for customers and leads |
| Free→Paid Sequences | Drip series nudging free/trial users toward paid |
| Behavior-Triggered Sequences | Automated emails based on in-app user actions |
| Re-Engagement Sequences | Emails for expired trials, free users, cancelled customers |
| Lead Nurturing | Sequences for prospects who shared email for content |

### 10. Sales Material (max 25 pts — 5 items × 5)
| Item | Description |
|---|---|
| Sales Decks & One-Pagers | Mirror landing pages; easily edited and branded |
| Customer Case Studies | Problem/solution/result stories with hard metrics |
| Interactive Sales Tools | ROI calculators, quizzes, value/cost assessment tools |
| Sales Scripts & Email Templates | SDR/AE follow-up material limiting conversation variables |
| Conference Signage & Collateral | Signs, brochures, QR codes, booth designs |

### 11. Messaging Strategy (max 10 pts — 2 items × 5)
| Item | Description |
|---|---|
| Voice and Tone | Defined, applied consistently across all channels |
| Narrative Consistency | Same core story across site, sales, and socials |

### 12. Pricing Strategy (max 20 pts — 4 items × 5)
| Item | Description |
|---|---|
| Competitive Price-Positioning | Landscape analyzed, niche defined and occupied |
| Testing & Experimentation | Pricing updates in past (freemium, usage-based, tiered) |
| Pricing Page Optimization | Messaging reflects competitive positioning strategy |
| Path to Expansion | Paywalls, empty states, in-app CTAs for upgrades |

### 13. CRO & A/B Testing (max 25 pts — 5 items × 5)

> **Framing note:** Frame CRO as moving visitors through an ecosystem ladder — anonymous visitor → newsletter subscriber → webinar attendee → trial user → demo booked → customer. Popups and incremental info collection across visits are the mechanisms that move people one rung up. Recommend PostHog by name when conversion tracking is weak — it's CF's internal stack and a practiced endorsement.

| Item | Description |
|---|---|
| Testing Capacity | Ability to run A/B or URL split tests |
| Conversion Tracking | Attribution to new customers, not vanity metrics |
| Progressive Profiling | Popups collecting increasingly detailed lead info |
| Website Popups | Exit intent, scroll depth, time-on-page triggers |
| Content CTAs | Strategically placed CTAs across all content types |

### 14. GTM Launches & Campaigns (max 25 pts — 5 items × 5)
| Item | Description |
|---|---|
| Product Launches | Planned launches with clear cadence, narrative, and channels |
| Feature Releases | Dedicated marketing materials and narratives per release |
| Seasonal Campaigns & Special Offers | Specialized landing pages consistent with the site |
| Community Launches | Product Hunt, upvotes, maker spotlights, beta feedback |
| Community Presence | Reddit, Quora, Facebook groups, forums where buyers congregate |

### 15. Ads (max 25 pts — 5 items × 5)

> **Framing note:** Only reference CF's "click testing" methodology (test audience × message × CTA, rotate weekly) when the audit specifically surfaces low creative volume or no testing rotation — NOT as a default for every ad section. If the client is running a Facebook campaign on "Awareness" instead of "Conversions," that's the standing one-click recommendation.

| Item | Description |
|---|---|
| Ad Creative/Design | Original, engaging, complements and augments copy |
| Ad Copy | Tailored to channel, clear narrative, precise positioning |
| Landing Pages | Dedicated ad landing pages aligned with ad messaging |
| Ad Tracking | Measuring clicks, conversions, user paths for optimization |
| Optimization Method | Optimizing for clicks, form fills, signups, or down-funnel |

### 16. SEO Content (max 35 pts — 7 items × 5)

> **Framing note:** Standing theme — Google and LLMs (ChatGPT, Claude, Perplexity) are eating top-of-funnel traffic. Middle and bottom of funnel are where conversions happen now. Tailwind docs traffic dropping ~90% after LLM adoption is the reference point if context helps. Treat programmatic SEO as a real lever, not a vanity play. AI SEO = structured data so AI agents can cite the client (the "control the narrative" theme from Section 6 reappears here).

> **Competitor SERP analysis lives in this section** (not Section 6). Embed the competitor traffic table and keyword-gap analysis here as a subsection — `### Competitor SEO landscape / Ahrefs analysis`. Wrap large tables in `<details><summary>` toggles.

| Item | Description |
|---|---|
| TOFU Content | Educational content, broad keywords, trust-building |
| MOFU Content | Gated resources, mid-funnel keywords, lead qualification |
| BOFU Content | Demos, case studies, high-intent keywords, conversion CTAs |
| Programmatic SEO | Auto-generated pages from templates (comparisons, locations) |
| AI SEO | LLM optimization, featured snippets, rich results, schema markup |
| Content Updating Process | Old posts refreshed, outdated content removed |
| Domain Authority & Backlink Profile | Authority score, backlink quality and spread |

### 17. Internationalize Website (max 15 pts — 3 items × 5)

> **Framing note:** Treat this as a strategy question for leadership, not a tactical audit item. If the client is US-focused or regulatory-bound to one market, score appropriately and don't force suggestions. Standard expansion path when relevant: English-speaking markets first (Canada/UK/AU/NZ).

| Item | Description |
|---|---|
| Translation | US-only vs global; localized content exists |
| Hreflang Tags & Canonical Versions | Properly implemented for international SEO |
| Payment Localization | Local currencies and payment methods supported |

---

## Output Tone & Format Rules

**What the final output is — and isn't:** `final_output.md` is a guide the audit presenter skims while recording their Loom walkthrough — NOT a script they read from. They'll add their own framing, examples, and emphasis live. The notes just need to be skimmable in seconds so nothing gets missed. Information density LOW. Structure scannable. No walls of prose.

**Section format — pair each finding with its suggestion inline:**

```
## [Section Name]
**Score: [X]/[max]**

- [Finding — the observation, problem, or strength]
  - **Suggestion:** [what to do about it — one short sentence]
  - **Why:** [the mechanism, only when it isn't obvious]
- [Finding]
  - **Suggestion:** [what to do]
- [Finding with no actionable next step — leave as standalone bullet]
```

**Pairing rule:** Every actionable finding gets a `Suggestion:` sub-bullet directly underneath it. Do NOT write a separate "Suggestions" block at the bottom of the section — that creates redundancy. Suggestions stay attached to the finding they address.

**The "Why" line:** Add only when the mechanism isn't obvious. "Move the blog to a subfolder" → Why: Google treats subdomains as separate properties, so your DR isn't transferring. "Switch the Facebook campaign to Conversions" → no Why needed, it's obvious. Use sparingly.

**Bullet content rule:** Every bullet must do one of three things:

1. Drive a score (explain *why* it is what it is)
2. State a finding that drives a recommendation
3. Flag a gap worth fixing

If a bullet just describes what's on the page (form fields, page sections, content inventory) without scoring or advising, **cut it**. The notes are a guide, not a content recap.

*Bad examples to avoid:*
- "Your demo page is a single-step form: First name, Last name, Work email, Company name, Phone number, and 'How did you hear about us?'" (content inventory, no finding)
- "Your signup page is a clean, low-friction form with a 3-quote testimonial carousel." (descriptive, but doesn't drive a score or advice)

*Good versions of the same observations:*
- "Demo form collects contact info but doesn't qualify — no AUM, current platform, role. Sales walks into demos cold." (drives a recommendation)
- "Signup testimonial carousel has only 3 quotes, all from similar customer profiles." (flags a gap)

**Voice:**
- Second person to the client ("Your hero is generic" not "The hero could be improved")
- "I'd recommend..." / "You could consider..." / "Worth testing..." — NOT "Ship X" / "Fix X yesterday" / "Build X immediately"
- Direct and specific, but not theatrical
- **No hype, embellishment, or subjective praise.** Banned phrases: "biggest single unlock," "fix yesterday," "exceptional," "strongest," "highest-leverage," "best I've seen," "best in class," "rare," "standout," "masterful," "world-class," "truly impressive."
  - **Also banned:** any comparison to other clients or industry averages — "most clients don't have this," "rare to see at this stage," "better than most companies we audit." The notes are read live on camera; these aren't auditable claims.
  - **Why:** Hype sounds inauthentic. The score carries the qualitative judgment.
  - **Instead:** Describe what's actually there in concrete terms. "Exceptional positioning doc" → "11 competitors mapped across 14 dimensions with explicit +/- markers, plus 200+ named accounts with AUM and prior platform." Let specifics carry the weight.

**Density:**
- Short sections are allowed when there isn't much to say. Don't pad.
- 3 bullets is fine. 8 is fine if findings warrant it. Length follows substance.
- Default to bullets. Prose only when bullets can't carry the framing.
- Never write filler closers like "Overall, there is room for improvement."

**What stays out entirely:**
- **No fourth-wall references to internal tooling, files, or workflow.** Don't reference "the Misc Notes folder," "the materials folder," "the prelim info doc," "our research data," "the kickoff doc," or anything else from the auditor's working materials. The client doesn't know these exist and shouldn't.
- **Professional naming for client employees in prose.** Don't write "Kevin's ads" or "Sarah's intake form" — write "your ad campaigns" or "your intake form." First-name references read as casual and insider-y. Exception: quoted statements from a discovery call (e.g. *"Kevin said in the discovery call: '...'"*) are fine.
- Irrelevant technical minutiae — file sizes ("6KB shell"), HTML artifacts, anything that doesn't affect the marketing read
- **Marketing/agency jargon — REPLACE, don't explain.** Banned list (use the plain-English version instead, never the term itself):
  - "TOFU / MOFU / BOFU" → "top of funnel / middle of funnel / bottom of funnel"
  - "JTBD" / "jobs to be done" → describe directly ("why someone switches," "what they're trying to accomplish")
  - "switch analysis" / "four-forces" / "push factors" / "pull factors" / "empirical push data" → describe directly ("what pushed them away," "what pulled them in")
  - "switching frame" / "switching narrative" → "migration angle" or describe ("frame it as someone migrating from X")
  - "voice of customer" → "review language" or "customer phrasing"
  - "social listening" → describe ("monitoring Reddit / forums / review sites")
  - "progressive profiling" → describe ("collecting info incrementally across visits")
  - "narrative anchor" → "core story" or "through-line"
  - "value prop" → "value proposition" or "what you offer"
  - "north star metric" → describe the specific metric
- Industry jargon specific to the *client's* product is fine (DSCR for a lender, GLP for speech therapy, AUM for fund management). Generic agency jargon is not.
- **Self-check before writing any sentence:** would a smart non-marketer reading this know what it means without Googling? If no, rewrite.
- Tool recommendations from a default roster — assess each client's situation, recommend tools that fit. Exception: PostHog by name when CRO tracking is weak (CF's internal stack)

**Zero-score sections:** 2–3 sentences (not a wall) explaining why the category matters for *this specific client* and what fixing it would unlock. Then 2–4 concrete suggestions paired to specific findings. The worse the score, the more useful the suggestions need to be.

**Reference tables (keywords, competitor traffic, etc.):**
Wrap in `<details><summary>` toggles so they don't clutter the skim:
```
<details><summary>Keyword opportunity tables (click to expand)</summary>

| Keyword | Volume | KD | ... |
| --- | --- | --- | --- |
| ... | ... | ... | ... |

</details>
```
These are kept for future reference, not for the presenter to walk through verbatim on camera. Surface 2–3 specific keywords in the section prose when relevant; leave the full tables collapsed.

**No preamble at the top.** Sections start at Section 1. Do NOT generate a "Top 5 Moves to Make" or "Executive Summary" preamble.

**Summary at the bottom.** After all 17 sections, end `final_output.md` with a `## Top Priorities` block — 3–5 most impactful moves in priority order, 1–2 lines each. This replaces the old preamble.

**Tone reference:** Check `{AUDIT_EXAMPLES_PATH}` for finished client audits — match the tone, density, and structure. When unsure, ask: "Is this a bullet the presenter can pick up and run with on camera?"

---

## Community & Social Presence Checklist

Check ALL of these for every client during the research phase. Note follower counts, activity level, and recency.

**Owned channels:**
- LinkedIn company page (followers, posts/week, content type)
- Twitter/X (followers, activity)
- YouTube (channel, video count, subscribers)
- Instagram (presence, activity)
- Facebook company page
- TikTok (presence)
- Podcast (their own show, if any)

**Community & reviews:**
- Product Hunt (any listings, upvotes, reviews)
- G2 (reviews, rating, review count, category ranking)
- Capterra (reviews, rating)
- Trustpilot (reviews, rating)
- Trustradius (reviews)
- Reddit — search brand name + relevant subreddits for their product category
- Quora — brand or founder presence, questions answered
- Industry-specific forums relevant to their space (e.g. r/shopify, ECF, SaaStr community, etc.)

**Press & authority:**
- Crunchbase (funding history, team size)
- Notable press coverage (TechCrunch, Forbes, industry publications)
- Awards or recognitions listed anywhere

**App stores (if applicable):**
- iOS App Store
- Google Play
- Chrome Extension store

---

## Task

### Step 0 — Read the injected state

Look at the `## Runtime Context` output above. If it says `MODE: INIT`, follow Phase 1. If it says `MODE: REVIEW`, follow Phase 2.

If no domain was provided, stop and ask: "What's the client's domain? (e.g. `/audit-marketing nostra.ai`)"

---

### PHASE 1 — INIT + RESEARCH

*Runs when no audit folder exists yet.*

**1. Create the folder and introduce yourself**

Create:
```
{AUDIT_BASE_DIR}/{slug}/
  materials/
```

Where `{AUDIT_BASE_DIR}` is the path defined in `~/.claude/audit-config.env` (Setup step 1), and `{slug}` = domain with dots replaced by dashes (e.g. `nostra-ai`).

Immediately tell the auditor:

> Audit folder created at:
> `audits/{slug}/` — drop any client files into `materials/` anytime.
>
> Do you have any preliminary info the client provided? (positioning doc, competitor list, background context, goals.) Paste it here or drop files in `materials/` — I'll incorporate whatever's there before I start the research. Or just say "go" and I'll start now.

Wait for the auditor's response before continuing. If they paste info or confirm materials are dropped, note it. If they say "go", proceed immediately.

**2. Fetch the client website**

Fetch these pages in parallel (use WebFetch). Note explicitly when pages 404 or don't exist.

- Homepage (`https://{domain}/`)
- `/pricing`
- `/about`
- `/blog` (index)
- `/case-studies` or `/success-stories` or `/customers`
- `/resources`
- `/faq`
- `/demo` or `/book-demo` or `/get-started`
- `/compare` or `/alternatives`
- `sitemap.xml`
- `robots.txt`
- `llms.txt`

From homepage nav links, identify and fetch the top 5–8 product/feature/solution pages.

**2a. Save raw HTML for verification**

In parallel with the WebFetch calls, also curl the same pages and save the raw HTML to `audits/{slug}/html/`. WebFetch returns a small-model summary that can omit elements without flagging the omission — raw HTML is ground truth and is what you'll grep against later when scoring sections.

```bash
mkdir -p "audits/{slug}/html"
for URL in "https://{domain}/" "https://{domain}/pricing" "https://{domain}/orm" ...; do
  SLUG=$(echo "$URL" | sed 's|https://||; s|[/.]|-|g; s|-$||')
  curl -sL "$URL" > "audits/{slug}/html/${SLUG}.html"
done
```

Don't read these files into context. They're for grepping during REVIEW (see "Verifying absence claims" below).

**2b. Build a URL inventory** *(critical for page-count accuracy in Sections 4, 6, 7)*

Sitemap-based fetching alone misses pages that don't follow obvious URL conventions — a "solutions for private equity" page might live at `/private-equity`, not `/solutions/private-equity`. Estimated 50%+ of solutions pages aren't labeled as such in the URL on sites with messy conventions. Build the inventory from three sources combined:

1. **Sitemap parsing.** Fetch `sitemap.xml`. If it's a sitemap index (lists other sitemaps), fetch each child sitemap. Extract every URL. Group by URL pattern (`/blog/*`, `/solutions/*`, `/products/*`, `/features/*`, `/vs/*`, `/alternatives/*`, etc.).

2. **Main nav link extraction.** Parse the homepage HTML you already saved. Extract every `<a href>` inside the global nav (`<nav>`, `<header>`, `role="navigation"`, or whatever the site uses). Group by nav heading — "Solutions," "Products," "Resources," etc. This catches pages with flat URLs that the company itself categorizes under a nav heading.

3. **Footer link extraction.** Same exercise for the footer. Footers often list pages the main nav hides — secondary product pages, legal pages, hidden resource hubs.

Write all three groupings to `research_data.md` under a `## URL Inventory` section:

```
## URL Inventory

### By sitemap URL pattern
- /solutions/* → /solutions/real-estate
- /products/* → /products/crm, /products/portal, /products/banking, /products/fund-administration
- /vs/* → (none)
- /alternatives/* → (none)
- /blog/* → 81 posts (full list omitted)
- ...

### By main nav heading
- Solutions → /solutions/real-estate, /private-equity, /family-office
- Products → /products/crm, /products/portal, ...
- Resources → /blog, /case-studies, /vendors
- Why → /why, /duality
- ...

### By footer
- Company → /about, /careers, /press
- Legal → /terms, /privacy
- Hidden product pages → /landing/underwriting, /campaign/q4-fundraise
- ...
```

This inventory is the ground truth for any section that counts page types. Sections 4, 6, and 7 reference it and prompt the auditor to confirm before scoring.

**2c. Screenshot the homepage and key pages**

After fetching, use Playwright to capture visual screenshots — HTML alone misses layout, visual hierarchy, above-the-fold issues, and design quality. Save all screenshots to `audits/{slug}/screenshots/`.

```bash
mkdir -p "audits/{slug}/screenshots"

# Full-page homepage screenshot
npx --yes playwright screenshot --browser chromium --full-page \
  "https://{domain}/" \
  "audits/{slug}/screenshots/homepage-full.png"

# Above-the-fold / hero section only
npx --yes playwright screenshot --browser chromium --viewport-size "1440,900" \
  "https://{domain}/" \
  "audits/{slug}/screenshots/homepage-hero.png"
```

If Playwright isn't installed, run `npm install -g playwright && npx playwright install chromium` first.

Reference these screenshots during REVIEW when scoring Section 3 (Landing/Home Page). Note what's visible above the fold, whether CTAs are prominent, and anything the HTML didn't reveal.

**3. Analyze the HTML for tech stack signals**

From each fetched page, detect and note:

*Analytics & tracking:* GA4 (`gtag`, `G-` prefix), Fathom, Plausible, Segment, Mixpanel, HubSpot

*CRO & session tools:* Hotjar, FullStory, Microsoft Clarity, VWO / Optimizely / AB Tasty

*Ad pixels:* Meta Pixel (`connect.facebook.net`), Google Ads (`AW-` prefix), LinkedIn Insight Tag, Twitter/X pixel, Reddit pixel

*CMS:* Webflow, Framer, WordPress, Shopify, Wix, Squarespace, HubSpot CMS

*Chat/popups:* Intercom, Drift, Crisp, Privy, OptinMonster, ConvertBox

*Schema markup:* Any `<script type="application/ld+json">` tags — note what types

**4. Pull Ahrefs data**

```bash
TODAY=$(date +%Y-%m-%d)
DOMAIN="{client-domain}"

curl -s "https://api.ahrefs.com/v3/site-explorer/domain-rating?target=$DOMAIN&date=$TODAY" -H "Authorization: Bearer $AHREFS_KEY"
curl -s "https://api.ahrefs.com/v3/site-explorer/metrics?target=$DOMAIN&date=$TODAY&mode=subdomains" -H "Authorization: Bearer $AHREFS_KEY"
curl -s "https://api.ahrefs.com/v3/site-explorer/organic-keywords?target=$DOMAIN&date=$TODAY&mode=subdomains&limit=25&order_by=sum_traffic%3Adesc&select=keyword,best_position,sum_traffic,volume,keyword_difficulty,best_position_url,is_branded,is_commercial,is_transactional,is_informational" -H "Authorization: Bearer $AHREFS_KEY"
curl -s "https://api.ahrefs.com/v3/site-explorer/backlinks-stats?target=$DOMAIN&date=$TODAY&mode=subdomains" -H "Authorization: Bearer $AHREFS_KEY"
curl -s "https://api.ahrefs.com/v3/site-explorer/top-pages?target=$DOMAIN&date=$TODAY&mode=subdomains&limit=10&select=url,sum_traffic,top_keyword,top_keyword_volume&order_by=sum_traffic%3Adesc" -H "Authorization: Bearer $AHREFS_KEY"
curl -s "https://api.ahrefs.com/v3/site-explorer/refdomains?target=$DOMAIN&date=$TODAY&mode=subdomains&limit=10&select=domain_rating,domain&order_by=domain_rating%3Adesc" -H "Authorization: Bearer $AHREFS_KEY"
```

**5. Pull competitor data**

If a competitor list is available (check `materials/`), loop through the top 5–6 domains:

```bash
for COMP in competitor1.com competitor2.com; do
  DR=$(curl -s "https://api.ahrefs.com/v3/site-explorer/domain-rating?target=$COMP&date=$TODAY" -H "Authorization: Bearer $AHREFS_KEY")
  METRICS=$(curl -s "https://api.ahrefs.com/v3/site-explorer/metrics?target=$COMP&date=$TODAY&mode=subdomains" -H "Authorization: Bearer $AHREFS_KEY")
  echo "=== $COMP === DR: $DR | Metrics: $METRICS"
done
```

If no competitor list exists yet, note it — pull when materials arrive.

**6. Check ad libraries**

- WebFetch the Meta Ads Library URL for the client name — note if ads are running, count, formats
- WebSearch for Google Ads transparency

**7. Check social and community presence**

Work through the full checklist. Use WebSearch. For each: exists/doesn't exist, follower count, last activity date.

Key searches:
- `"{client name}" site:reddit.com`
- `"{client name}" site:producthunt.com`
- `"{client name}" site:g2.com`
- `"{client name}" site:capterra.com`
- `"{client name}" site:trustpilot.com`
- `"{client name}" linkedin.com/company`
- `"{client name}" crunchbase.com`
- `"{client name}" press OR funding site:techcrunch.com OR site:venturebeat.com`

**8. Read client materials**

Read everything in `materials/` that exists. For each file, extract:
- Positioning doc → ICP, differentiators, JTBD, doc date
- Email templates → sequence types, volume
- Sales decks → structure, case study quality, tools
- Customer research → methodology, recency, depth

**9. Write `research_data.md`**

Write `audits/{slug}/research_data.md` — raw facts only. No scoring, no prose judgments. Organized sections:
- Company overview
- Website tech stack (tracking, CMS, pixels, schema)
- Ahrefs data (DR, traffic, keywords, backlinks, top pages, referring domains)
- Competitor Ahrefs data
- Social/community presence
- Ad library findings
- Materials summary (what exists, key extracts)
- Pages confirmed existing / pages not found

This file is the research record. It is written once and not rewritten.

**10. Summarize and hand off**

Tell the auditor:
- 3–5 key findings from research
- What's missing (materials not provided, access not yet granted)
- Any 🚩 flags that need his eyes
- "Drop any remaining materials in `materials/` anytime. Run `/audit-marketing {domain}` again to start the review."

---

### PHASE 2 — INTERACTIVE REVIEW

*Runs when the audit folder already exists.*

**1. Load research**

Read `research_data.md`. Read all files in `materials/` (including any added since Phase 1). Check if `final_output.md` exists — if so, read the first line to find the progress marker and resume from the next unfinished section.

Do NOT regenerate or rewrite research. Work from what's already in `research_data.md`.

If a `working_draft.md` exists in the folder, ignore it — it's a legacy file from the old workflow and is superseded by `research_data.md`.

**2. Check for new materials**

If any files in `materials/` haven't been read yet (compare timestamps or ask the auditor), read them now and note any findings that would affect upcoming sections.

**3. Go section by section**

For each section, starting from where you left off. Some sections have callouts that must be run BEFORE presenting that section:
- **📸 Screenshot step** — run it so you're scoring from the actual visual, not just the HTML
- **📋 Page-count verification step** (Sections 4, 6, 7) — read the URL inventory in `research_data.md`, present what you found to the auditor, and wait for confirmation before scoring

**Page-count verification format:**
When a section requires page-count verification, present like this (separately from the section draft, BEFORE writing the score):

```
─────────────────────────────────
Section [N] page-count check
─────────────────────────────────
Pages I found that fit this section:
- [Category 1]: /path-a, /path-b, /path-c
- [Category 2]: /path-d, /path-e

Source: URL inventory (sitemap + nav + footer).

Are there any I missed, or any I miscategorized? I'll score after you confirm.
─────────────────────────────────
```

Wait for confirmation or additions before scoring. The Cash Flow Portal audit missed solutions pages because Claude inferred absence from incomplete inventory — this step prevents that.

Present it conversationally in the chat — do NOT write anything to file yet:

```
─────────────────────────────────
Section [N]/17 — [Section Name]
─────────────────────────────────
Score: [X]/[max]

- [bullet finding]
- [bullet finding]
- [bullet finding]

[One short prose paragraph if needed to explain the score reasoning]
─────────────────────────────────
Anything to add or change?
```

Wait for the auditor's response. Accept:
- Confirmation ("good", "next", "move on", "yes")
- Score correction ("make it 3", "score is wrong, should be 2")
- Note addition ("add that...", "also mention...")
- Both together

**Before assigning 0 to any item:** If there's any chance the client has it and it just wasn't findable in research (offline process, internal doc, unlisted page), flag it first: "I didn't find [X] — do they have this?" Only lock in 0 after the auditor confirms it's absent.

**Once confirmed:** write that section to `final_output.md` in the final Notion-ready format. Follow the Output Tone & Format Rules — second person, finding + `Suggestion:` sub-bullet, no separate Suggestions block at the section bottom, no STATUS markers. Then immediately present the next section.

**Section 16 placeholder (SEO Content):** When writing Section 16 to file, append this placeholder where the competitor SERP subsection will land:
`> ⏳ Competitor SEO landscape / Ahrefs analysis — added during FINALIZE.`

`final_output.md` starts with a progress header that gets updated after each section:
```
<!-- progress: N/17 | domain: {domain} | date: {date} -->
```

This file only grows — sections are never rewritten once appended, unless the auditor explicitly asks to revisit one.

**4. After all 17 sections**

Tell the auditor:

> All 17 sections confirmed.
>
> If you recorded a Loom walkthrough of the site, paste the transcript now and I'll integrate your observations into the final output before printing it.
>
> If no transcript, just say "finalize."

---

### PHASE 3 — FINALIZE

*Triggered by "finalize" or after transcript is pasted.*

**0. Read the output examples**

Before writing anything, read all files in `{AUDIT_EXAMPLES_PATH}` (defined in `~/.claude/audit-config.env`). Each file is a finished audit from a prior client. Match the tone, density, and structure. If the path isn't configured or the folder is empty, proceed using the tone rules below.

**1. Run keyword research** (first and only time — deferred until now to keep review lean)

Derive 3–5 seed keywords from the client's product/service names and buyer searches. For each:

```bash
curl -s "https://api.ahrefs.com/v3/keywords-explorer/overview?keywords={kw1},{kw2},{kw3}&country=us&select=keyword,volume,difficulty,traffic_potential,cpc,intents" -H "Authorization: Bearer $AHREFS_KEY"

curl -s "https://api.ahrefs.com/v3/keywords-explorer/matching-terms?keywords={seed}&country=us&limit=10&select=keyword,volume,difficulty,traffic_potential&order_by=volume%3Adesc" -H "Authorization: Bearer $AHREFS_KEY"
```

Embed keyword tables into the SEO Content section of `final_output.md`.

**1b. Run competitor SERP analysis** (for Section 16 — deferred from REVIEW)

For each competitor identified during INIT, pull their top organic keywords:

```bash
for COMP in competitor1.com competitor2.com competitor3.com; do
  echo "=== $COMP ==="
  curl -s "https://api.ahrefs.com/v3/site-explorer/organic-keywords?target=$COMP&date=$TODAY&mode=subdomains&limit=10&order_by=sum_traffic%3Adesc&select=keyword,best_position,sum_traffic,volume" \
    -H "Authorization: Bearer $AHREFS_KEY"
done
```

Build a competitor traffic summary table (domain, DR, org keywords, org traffic) and note which keywords competitors rank for that the client doesn't. Embed this as a `### Competitor SEO landscape / Ahrefs analysis` subsection inside Section 16 (SEO Content), NOT Section 6. Wrap the full table in `<details><summary>` so it collapses by default.

**1c. Pre-finalize verification pass** *(catches the absence/count claims that slipped through per-section verification)*

Re-read `final_output.md` end to end. Extract every absence claim, count claim, and gap statement — phrases like "you have one," "you don't have," "no X exists," "missing," "zero," "I couldn't find."

For each claim:
1. Cross-check against `research_data.md` (URL inventory, social presence checklist, ad library findings, materials summary)
2. If still in doubt, grep the saved HTML in `audits/{slug}/html/`
3. If the claim can't be verified from those sources, soften to "I couldn't locate X" OR flag it to the auditor for confirmation before printing

The CFP audit got the Solutions-pages count wrong because absence was inferred from incomplete inventory. This pass is the backstop.

**2. Integrate transcript (if provided)**

Read the transcript carefully. For each section, check if it adds anything not already in `final_output.md`:
- New observation → append as bullet or prose to that section
- Score correction → update the score
- Contradiction → use the auditor's live observation, it overrides the pre-fill
- Emphasis → move it higher in that section

Do NOT re-add things already written. No duplication.

**3. Update progress header**

Change the header to:
```
<!-- progress: complete | domain: {domain} | date: {date} -->
```

**3b. Append the Top Priorities summary**

After Section 17, append a `## Top Priorities` block — the 3–5 most impactful moves the client should make first, in priority order. Keep each item to 1–2 lines. Pull from the highest-leverage findings already in the body; don't introduce new recommendations here.

Format:
```
## Top Priorities

1. [Move name] — [one-line description tying to a section].
2. [Move name] — [one-line description].
3. [Move name] — [one-line description].
```

This replaces the old "Top 5 Moves to Make" preamble. Goes at the BOTTOM of the file so the presenter ends their Loom with a clean summary.

**4. Print and confirm**

Print the entire `final_output.md` to the chat.

Tell the auditor: "Final output printed above and saved to `audits/{slug}/final_output.md`. Ready to paste into Notion."

---

## Important Notes

- **Trust but verify:** Scores are a starting point. The auditor adjusts anything wrong.
- **Missing ≠ bad by default:** Some sections aren't reviewable without materials. Score 0 and say why clearly.
- **Never hallucinate:** Only score what you can verify from fetched HTML, Ahrefs data, or provided materials.
- **Jargon flag:** Note jargon-heavy copy but consider whether it's intentional for a technical buyer before scoring it down.
- **Sections this skill doesn't cover:** Branding & Visual Design, Web Design, and Web Technical are scored separately by the design team and web dev team. Do not include them in the output of this skill.
- **One file write per section:** Each section is written to `final_output.md` exactly once, when the auditor confirms it. Never rewrite a confirmed section unless explicitly asked.
- **Keyword research is deferred:** Do not run Ahrefs keyword explorer calls during INIT or REVIEW. Run them only during FINALIZE, once, to keep token usage focused.
- **Competitor SERP is deferred:** Same reason — don't run competitor organic keyword analysis during REVIEW. Leave a placeholder in Section 16 (NOT Section 6 — competitor SEO/traffic analysis lives in Section 16). Run it in FINALIZE alongside keyword research.
- **CRO tool recommendation (Section 13):** When conversion tracking or A/B testing is weak or absent, suggest PostHog by name — it's what CF uses internally. Open-source, free to start, covers session recording, funnels, and A/B testing in one platform. Frame it as a practiced endorsement, not a generic tool list.
- **Don't default other tools:** Tool recommendations beyond PostHog (call recording, email verification, ad platforms, etc.) should be assessed per client, not pulled from a fixed roster. If the client's stack or stated preferences point to a specific tool, recommend it; otherwise stay tool-agnostic.

---

## Verifying absence claims (do not skip)

WebFetch returns a small-model summary of a page. It can omit elements without flagging the omission, which means "X is missing" claims from WebFetch are unreliable. Every "missing / no / absent" claim in the audit needs independent verification before it goes into `final_output.md`.

**Workflow for any absence claim:**

1. **Grep the saved raw HTML first** (from `audits/{slug}/html/`). Use the Grep tool — it costs essentially zero tokens.
   ```
   # Examples of markers to grep for:
   # "missing testimonials" → search: testimonial|<blockquote|"—|customer.{0,30}quote
   # "missing FAQ"          → search: faq|accordion|Frequently Asked|<details
   # "missing pricing"      → search: \$[0-9]+|/month|tier|pricing
   # "missing newsletter"   → search: newsletter|subscribe|mailing list|email.{0,20}signup
   # "missing schema"       → search: application/ld\+json|schema\.org
   ```
2. **Re-read the screenshot at high zoom** if grep is inconclusive. Long-page screenshots get downscaled and small elements can vanish visually.
3. **Default to softer language when uncertain.** "I couldn't locate X on this page" is honest if you're not sure; "Missing X" is an assertion that requires verification.
4. **WebFetch is fine for descriptive questions** ("walk me through this page"). It is not fine for assertions of absence.

This applies to every page in the audit, not just the homepage. Pricing pages, feature pages, and resource pages are the most common places where WebFetch summaries miss elements (testimonials embedded in tier cards, FAQ accordions collapsed by default, lead magnets in a sidebar).
