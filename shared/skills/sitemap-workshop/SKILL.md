---
name: sitemap-workshop
description: "Stage 4: Sitemap Workshop — map the entire site architecture, lock down every integration, define every user happy path. The most critical integration checkpoint in the entire process. Use when planning site structure."
---

# Stage 4: Sitemap Workshop

You are guiding a CF team member through the Sitemap Workshop. This is the most critical integration checkpoint in the entire process — every integration need, every happy path, and every content migration requirement must be documented here. Nothing should surface for the first time at launch.

## Context

**Goal**: Map the entire site architecture, lock down every integration, define every user happy path, and give every team a complete picture of what's being built — so the design and dev teams can rip without surprises.

**Owner**: Nick's Team (Webflow Dev, Sitemap & Integrations)
**Supports**: Zach's Team (page-level design thinking), Corey's Team (content requirements per page, integration direction), PM (client communication)
**Tools**: Relume (sitemap framework, component library), Google Meets + SavvyCal, Notion AI (meeting recording), Notion (documentation)
**Prerequisites**: Stage 2 (Positioning) completed. Stage 3 (Brand Strategy) completed if applicable.

## Workflow

Ask the user: **What client are we mapping? Do you have the Relume library set up?**

### Step 1: Pre-Workshop Preparation

**Claude automation**:
- Generate the integration requirements map template pre-populated with the client's known tech stack from Stage 0
- Compile all known integrations from preliminary info collection
- Draft initial sitemap based on standard SaaS structure (Relume library as starting framework)

### Step 2: Workshop Execution

Nick leads the workshop covering:
1. **Page tree**: Every page, page relationships, hierarchy
2. **Page types**: Static vs. dynamic (CMS), templated pages
3. **External tool connections**: Per page
4. **User happy paths**: What happens after form submissions, redirects, confirmation pages
5. **CMS architecture**: Collections, fields, relationships, who manages content post-launch
6. **Content migration**: What existing content needs to come over
7. **Platform decision**: AI Native (Next.js), Webflow, or Framer — confirmed here if not already
8. **Language/localization**: Target markets, languages, typeface character support

**Claude automation during workshop**:
- Produce a per-page integration checklist in real time
- Flag common integration pitfalls based on platform choice
- Draft the CMS architecture brief (collections, fields, relationships)
- Map all happy paths into a document

### Step 3: Integration Requirements Map

For EVERY page, document:
- Forms: where do they submit? (HubSpot, Mailchimp, custom endpoint)
- Email capture: what list/sequence does it trigger?
- Analytics: what events need tracking?
- CMS: what collections feed this page? What fields?
- Auth: does this page require login?
- Third-party embeds: calendars, chat widgets, payment processors
- Webhooks: external workflow triggers?
- Happy path: what happens after the user takes action on this page?

### Step 4: Integration Checkpoint

- Client must confirm ALL third-party tools and credentials
- Any tool the client "might want later" gets documented with status (confirmed / tentative / future)
- Nick's team flags integrations requiring dev work, API keys, or third-party account setup
- Corey's team confirms email platform, CRM, and marketing tool connections
- Timeline impact of each integration noted
- All happy paths defined — no post-action states left undefined

## Deliverables

1. **Sitemap document** — full page tree with hierarchy, page types, and relationships
2. **Integration requirements map** — for every page (see template)
3. **Happy paths document** — every user flow mapped
4. **CMS architecture brief** — collections, fields, relationships, content management
5. **Content migration plan** — what existing content comes over
6. **Platform decision** — AI Native, Webflow, or Framer confirmed
7. **Language and localization requirements** — target markets, languages, typeface support

## Non-Negotiable Checklist

- [ ] Complete sitemap document with every page, page type, and hierarchy
- [ ] Integration requirements map completed for every page — no blanks
- [ ] Every happy path defined (post-form, post-signup, post-purchase, etc.)
- [ ] CMS architecture brief with collections, fields, and relationships
- [ ] Content migration plan (what's coming over from the old site)
- [ ] Platform confirmed (AI Native, Webflow, or Framer)
- [ ] All third-party tools and credentials confirmed or flagged with status
- [ ] Language and localization requirements documented
- [ ] Typeface character support needs identified for target markets
- [ ] Client has signed off on the sitemap and integration plan
