---
name: client-intake
description: "Stage 0: Client Intake & Sales — sales calls, preliminary info collection, and the 99-point audit. Use when onboarding a new client or starting any engagement."
---

# Stage 0: Client Intake & Sales

You are guiding a CF team member through the client intake process. This stage has three sub-stages that must be completed in order.

## Sub-Stages

Ask the user which sub-stage they're working on, or start from the beginning:

### 0A: Sales Call

**Goal**: Determine whether the client is a fit, what type of engagement makes sense, and get them started on the right path.

**Owner**: Founders / PM
**Supports**: All team leads (scoping their respective areas)
**Tools**: SavvyCal (scheduling), Slack (notifications), Google Meets (call)

**Process**:
1. Sales call booked through SavvyCal, team notified via Slack
2. Client indicates engagement type: custom project, subscription, or audit
3. The audit is recommended as the best starting point regardless of engagement type
4. If client skips audit, determine where they fall in the REO sequence (Revolution, Evolution, or Optimization) and scope accordingly
5. Some clients just need augmentation — extra muscle for copywriting, design, and web dev

**What Claude does**:
- Pre-generate a scoping summary based on initial client info before the sales call
- Ask: What do you know about this client so far? (company name, website, what they're looking for)
- Generate a brief scoping summary covering: likely engagement type, potential REO classification, key questions to ask on the call

**Checklist — you must leave this sub-stage with**:
- [ ] Engagement type decided (audit, subscription, fixed-price, augmentation, or combination)
- [ ] Client added to Slack channel
- [ ] Kickoff date or preliminary info request scheduled

---

### 0B: Preliminary Info Collection

**Goal**: Collect everything the team needs to begin work — client tools, assets, access, and context — so nothing has to be chased down later.

**Owner**: PM (sends and tracks completion)
**Supports**: All team leads (reviewing their sections)
**Tools**: Notion (preliminary info template), Slack, client's own tools

**What gets collected**:

**General**:
- Competitors list (up to 10 with website links)
- Product/explainer videos
- Sales material (decks, one-pagers, collateral)
- Free product account access
- SaaS metrics/financials (Stripe, Chartmogul, Paddle, RevenueCat)
- Pricing change history (last 2 years)

**Marketing** (invites to team@conversionfactory.co):
- Customer research recordings, surveys, or testimonials
- Existing positioning doc
- Email/lifecycle marketing access
- Web analytics access (GA, Fathom, PostHog, etc.)
- CRO tool access
- Full marketing funnel tooling (ESP, CRM, lead nurturing tools, and how they connect)
- Target markets and languages (current and planned expansion)

**Design** (invites to zach@conversionfactory.co):
- Figma access
- Brand style guide
- Any ads not visible from Meta Ad Library

**Web Dev** (invites to nick@conversionfactory.co):
- Website platform access (shareable link)
- Hosting and CMS details
- All integrations in the marketing funnel (HubSpot, Mailchimp, ConvertKit, etc.)

**What Claude does**:
- Pre-generate the preliminary info request customized per client
- Flag missing items and suggest follow-up messages
- Begin building the centralized client data profile (competitors, tools, metrics — collected once, used everywhere)
- Ask: What client are we collecting info for? Do you have their website URL and any initial context?

**Checklist — you must leave this sub-stage with**:
- [ ] All sections of the preliminary info request filled out or explicitly marked as N/A
- [ ] Access granted to all client tools (analytics, CRM, ESP, web platform, CMS, hosting)
- [ ] Competitor list documented
- [ ] Client's full marketing funnel tooling captured (every integration, every tool, every connection)
- [ ] Target markets and languages identified
- [ ] All info stored in the centralized client data profile in Notion

---

### 0C: The 99-Point Audit

**Goal**: Give the client a scored, prioritized roadmap of everything CF can do for them, so they can make informed decisions about what to tackle and in what order.

**Owner**: All three team leads (each covers their domain)
**Supports**: PM (delivery, client communication)
**Tools**: Notion (audit delivery, scorecards, task population), Loom (overview videos), client tools for review

**Process**:
1. Comprehensive audit of the client's entire marketing funnel
2. Delivered over one week via Notion
3. Scorecards covering every element being evaluated
4. Loom overview videos from each department head (design, marketing, web dev)
5. Post-audit: client reviews and decides what to pursue
6. Roadmap generated showing recommended tasks in CF's sequenced order

**What Claude does**:
- Help generate audit findings and scores based on available client data
- Pre-populate the post-audit roadmap with recommended tasks in sequence
- Draft the roadmap with estimates on subscription duration vs. fixed-price vs. combination
- Auto-populate Notion tasks based on the client's selections
- Ask: Which department's audit are you working on? What client data do you have access to?

**Checklist — you must leave this sub-stage with**:
- [ ] All 99 points scored
- [ ] Loom video from each department (design, marketing, web dev)
- [ ] Audit delivered to client via Notion
- [ ] Client has reviewed and selected which recommendations to pursue
- [ ] Roadmap generated with selected tasks in CF's recommended sequence
- [ ] Engagement scope, timeline, and pricing confirmed based on selections
- [ ] Notion project dashboard populated with tasks
- [ ] All client marketing funnel integrations documented in the web dev section
