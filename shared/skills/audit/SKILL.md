---
name: audit
description: "Product Marketing Audit — comprehensive audit across marketing, design, and web dev with scored categories, video walkthroughs, and a prioritized roadmap. Use when onboarding a new client or evaluating an existing one."
---

# Product Marketing Audit

You are guiding a CF team member through a comprehensive Product Marketing Audit. This audit scores a client's existing marketing, brand, and website across three disciplines, then produces a prioritized roadmap of recommended actions.

## Context

**Goal**: Evaluate a client's full marketing presence — positioning, brand, website, content, conversion, and growth — then deliver scored findings with a prioritized roadmap.

**Owners**: All three teams collaborate.
- **Marketing & Copy (Corey's team)**: Positioning, customer research, homepage, sales pages, conversion pages, competitor pages, resources, onboarding, email, messaging, pricing, CRO, GTM, ads, SEO, AI SEO, internationalization
- **Design (Zach's team)**: Creative direction, typography & layout, color, pattern & texture, shapes & graphics, logo, icon libraries, application across assets, style guide
- **Web Dev (Nick's team)**: Style guide (technical), CMS, interactions, class structure, site editing/maintenance, design implementation

**Tools**: Ahrefs, PostHog, Google Analytics, Figma, Webflow/Framer/platform access, Loom, Notion
**Prerequisites**: Client intake completed, preliminary info collected

## Phase 0: Preliminary Info Collection

Before the audit begins, collect all of the following from the client:

### General
- [ ] List of up to 10 competitors with website links
- [ ] Product videos / explainer videos
- [ ] Sales material (sales decks, one-pagers, collateral)
- [ ] Free product account
- [ ] SaaS metrics/financials if comfortable (Stripe, ChartMogul, Paddle, RevenueCat)
- [ ] Any pricing changes in the last 2 years

### Marketing (invites to team@conversionfactory.co)
- [ ] Customer research recordings, surveys, or testimonials
- [ ] Positioning doc (if exists)
- [ ] Email/lifecycle marketing platform access
- [ ] Web analytics access
- [ ] CRO tool access

### Design (invites to zach@conversionfactory.co)
- [ ] Figma access
- [ ] Brand style guide
- [ ] Any ads not visible from the Meta Ad Library

### Web Dev (invites to nick@conversionfactory.co)
- [ ] Website platform access (Webflow, Framer, WordPress, etc.)

---

## Phase 1: Marketing Audit (Corey's Team)

Evaluate each category below. For each one:
1. Summarize the current state
2. Identify strengths and gaps
3. Provide specific, actionable recommendations

Deliver a Loom video walkthrough of marketing findings.

### 1. Positioning
- Is there a documented positioning strategy?
- Are ICPs clearly defined with real traits (not just job titles)?
- Are differentiators well articulated?
- Is there a JTBD / switching dynamics analysis grounded in real customer evidence?
- **Recommendation format**: What to keep, what to sharpen, what's missing.

### 2. Customer Research
- Does a centralized research repository exist?
- Are there customer interviews, surveys, or review mining in place?
- Is research being used to inform messaging and page creation?
- **Key sources to evaluate**: Direct interviews, surveys, community research (Reddit, Facebook, Quora), support tickets, testimonials, review sites.

### 3. Homepage / Landing Page
- Is the hero section strong? (headline, subheadline, CTA, visual)
- Is there a clear How It Works section?
- Is social proof sufficient and varied? (testimonials, logos, stats, reviews)
- Are features presented as benefit-driven (feature → what it does → why you should care)?
- Is there a founder/trust-building section?
- Is CTA coverage sufficient throughout the page?
- Are objections handled near the bottom?
- Is the FAQ section strong and informed by real questions?

### 4. Sales / Feature Pages
- Do dedicated feature pages exist?
- Are there use case pages or persona pages?
- Do pages connect feature → benefit → outcome?

### 5. Conversion / Pricing Pages
- Is the pricing page fully built out with clear tier differentiation?
- Does messaging continue the narrative from the homepage?
- Is there a clear signup/demo conversion flow?
- Are conversion-focused elements present (risk reversal, objection handling)?

### 6. Competitor Comparison Pages
- Do comparison pages exist for key competitors?
- Are they SEO-optimized for "[competitor] alternative" and "vs" queries?
- Is the narrative fair but clearly favorable?

### 7. Resources / Content
- Is there a blog or content hub?
- Is there a mix of TOFU, MOFU, and BOFU content?
- Are there downloadable resources or lead magnets?
- Is content being repurposed across channels?

### 8. Onboarding
- Is the first-run experience clearly explained on-site?
- Is there a How It Works or installation walkthrough?
- Are there tooltips, guided setup, or onboarding flows in-product?
- Is there a path to a first "wow moment"?

### 9. Email Marketing
- Are these sequences in place: welcome, onboarding, nurture, re-engagement, upgrade/upsell?
- Is the email list segmented (prospects, free users, paid users)?
- Are broadcasts being sent regularly?
- Is email capture optimized on the site?

### 10. Sales Material
- Do case studies exist?
- Are there sales decks, one-pagers, or collateral?
- Is material aligned with current positioning and messaging?

### 11. Messaging Strategy
- Is voice and tone consistent across all touchpoints?
- Does messaging align with positioning?
- Is customer language being used (not company language)?

### 12. Pricing Strategy
- Is pricing clearly presented and easy to understand?
- Has competitive pricing analysis been done?
- Does the value narrative support each tier?

### 13. CRO / A/B Testing / Analytics
- Is analytics properly instrumented? (funnels, attribution, UTM tracking)
- Are CTAs placed at key decision points?
- Is there an A/B testing program or capability?
- Are pop-ups or progressive profiling in use?

### 14. GTM / Launches / Campaigns
- Is there a structured launch strategy?
- Are all launch assets aligned? (product, pricing, landing page, emails, ads)
- Is there a feature release strategy?
- Are community, podcast, and influencer channels being leveraged?

### 15. Ads
- Are campaigns running or have they run recently?
- Is there dedicated ad creative and copy?
- Are there ad-specific landing pages?
- Is tracking and optimization methodology in place?

### 16. SEO Content
- What is the current domain rating and trajectory?
- Are key page types being created? (blog, comparison, use case, feature, integration)
- Is there a programmatic SEO strategy?
- What is the keyword ranking landscape?

### 17. AI SEO
- Does an `llms.txt` file exist?
- Is FAQ schema markup in place?
- Is SoftwareApplication schema in place (for software products)?
- Do structured comparison pages exist for AI citation?
- Is there evidence of AI search referral traffic?

### 18. Internationalization
- What percentage of traffic comes from non-English-speaking countries?
- Is the site available in other languages?
- Is there a localization strategy?
- Does the product support multilingual use?

---

## Phase 2: Design Audit (Zach's Team)

Score each category **1–5**. For each:
1. Explain why it matters
2. Describe the current state
3. Provide specific recommendations

Deliver a Loom video walkthrough of design findings.

**Framework recommendation**: Classify the client as needing **Revolution** (ground-zero rebuild), **Evolution** (keep what works, fix what doesn't), or **Optimization** (solid foundation, poor execution).

### 1. Distinct Creative Direction (score /5)
- Is there an emotional foundation driving the brand?
- Are there identifiable muses or cultural reference points?
- Does the brand feel distinct from competitors or generic?

### 2. Typography & Layout (score /5)
- Are typeface choices intentional and well-executed?
- Is there a clear type scale with deliberate size contrast?
- Are layouts consistent? (alignment, container relationships, visual noise)

### 3. Color (score /5)
- Is the palette distinct and intentional?
- Is the CTA color differentiated from decorative elements?
- Is color usage balanced or overwhelming?

### 4. Pattern & Texture (score /5)
- Is pattern used as a unifying brand asset?
- Is it applied consistently across materials?
- Is it leveraged to its full potential?

### 5. Cohesive Shapes & Graphics (score /5)
- Is shape language consistent? (corner radii, containers, buttons)
- Are elements well-composed on the page?
- Is spacing and alignment tight?

### 6. Logo (score /5)
- Is it SAD? (Simple, Appropriate, Distinct)
- Does it scale from favicon to billboard?
- Is it easily identifiable and memorable?
- Does it stand apart from competitors?

### 7. Defined Icon Libraries (score /5)
- Is there a consistent utility icon set?
- Are outline vs. fill styles consistent?
- Is there a storytelling tier of icons beyond utility?

### 8. Application Across Assets (score /5)
- Is the brand consistent across all touchpoints? (website, emails, social, product UI, sales materials)
- Are there visible inconsistencies between channels?

### 9. Style Guide (score /5)
- Does a style guide exist?
- Does it cover type scale, color usage rules, and component patterns?
- Is it being followed with discretion?

---

## Phase 3: Web Dev Audit (Nick's Team)

Evaluate using the checklist below. Check or flag each item.

Deliver a Loom video walkthrough of web dev findings.

### Style Guide (Technical)
- [ ] Style guide is available on the site/platform
- [ ] Typography uses variables
- [ ] Headings, body text, rich text, HTML tags, text sizes, text weights defined
- [ ] Buttons: primary, secondary, link, alternate, with icon, size small, hover states
- [ ] Color palette uses variables
- [ ] Icons: consistent format (HTML embeds), sizes defined

### CMS
- [ ] CMS is utilized for structured content
- [ ] Collections coordinate together (reference and multi-reference)
- [ ] Conditional visibility and filters in use
- [ ] Utility collections (FAQ, team, etc.) are unpublished templates
- [ ] External URLs to collection items used sparingly
- [ ] Connected to external database for management (optional)

### Interactions
- [ ] Interactions are used sparingly and with intention
- [ ] Unused interactions are removed
- [ ] Interactions are cohesive in timing/feel and on-brand
- [ ] Lottie animations used in place of on-site JS when possible

### Class Structure
- [ ] Sizing structure is adhered to (tiny, small, medium, large)
- [ ] No random classes (e.g. "Div Block 754")
- [ ] Unused classes are cleaned up
- [ ] No class duplicates (e.g. "button 2")
- [ ] Uses a naming convention (Client-First, MAST, Lumos, etc.)
- [ ] Utilizes symbols/components

### Site Editing / Maintenance
- [ ] Client knows how to use editor
- [ ] Client knows how to use CMS
- [ ] Nuanced collections have tutorial videos
- [ ] Publishing/scheduling understood
- [ ] Client knows how to access site settings

### Design Implementation
- [ ] Uses REM instead of pixels
- [ ] Operates on 2, 4, 8 scaling
- [ ] Images served in proper formats (WebP, AVIF for raster; SVG for vector; native import when possible)
- [ ] Branded graphics in use
- [ ] Uniform page padding

---

## Phase 4: Recommended Actions & Roadmap

After all three teams complete their audits:

1. **Each team records a Loom video** walking through their findings
2. **Compile a unified Recommended Actions section** organized by discipline (Marketing, Design, Web Dev)
3. **Prioritize by impact** — what moves the needle most for this client right now?
4. **Map recommendations to CF stages** — which actions correspond to which stage of the master workflow?
5. **Include an Internal Marketing Notes section** with raw research, traffic analysis, competitor data, and anything that informed the recommendations

### Deliverables
- Notion page with full audit findings, scores, and checklists
- Loom video per discipline (Marketing, Design, Web Dev)
- Loom overview video summarizing the top-level findings
- Prioritized roadmap of recommended actions
- Internal notes section (not shared with client)

## REO Framework Classification

At the end of the audit, classify the client's needs using CF's REO framework:

| Discipline | Revolution | Evolution | Optimization |
|-----------|-----------|----------|-------------|
| Positioning | | | |
| Branding & Design | | | |
| Website | | | |

This classification informs how the engagement is scoped if the client proceeds.

## Non-Negotiable Checklist

- [ ] All preliminary info collected before audit begins
- [ ] Marketing audit: all 18 categories evaluated with recommendations
- [ ] Design audit: all 9 categories scored 1–5 with recommendations
- [ ] Web dev audit: full checklist completed
- [ ] Loom video recorded per discipline
- [ ] Overview Loom video recorded
- [ ] Recommended actions compiled and prioritized
- [ ] REO framework classification completed
- [ ] Notion page delivered to client
- [ ] Internal marketing notes documented (not shared with client)
