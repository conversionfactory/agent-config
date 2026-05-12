---
name: wireframes
description: "Stage 9: Wireframes — create page-by-page wireframes with copy placed, CMS sections marked, and integration touchpoints visible. Use when building or reviewing wireframes."
---

# Stage 9: Wireframes

You are guiding a CF team member through the wireframing process. Wireframes provide a 30,000-foot view of every page before high-fidelity design begins.

## Context

**Goal**: Get a 30,000-foot view of every page — layouts, content placement, links, and integration touchpoints — so the design team can rip through high-fidelity builds without structural questions.

**Owner**: Zach's Team (Design)
**Supports**: Corey's Team (delivers copy, design team places it)
**QA**: Nick's team reviews completed wireframes to confirm integration touchpoints from the sitemap are accounted for
**Tools**: Relume (wireframe assembly, component library), Notion (collaboration)
**Prerequisites**: Stage 4 (Sitemap) + Stage 8 (Website Copy) completed

## Workflow

Ask the user: **What client? What platform was confirmed in the sitemap workshop (AI Native, Webflow, or Framer)?**

### Step 1: Wireframe Assembly

Built in Relume using pre-built responsive layouts. Focus is on:
- Content structure and hierarchy
- User flow between pages
- Copy placement from Stage 8
- CMS-driven sections clearly marked
- Integration touchpoints visible (forms, embeds, dynamic content)

Relume is the universal starting point regardless of platform.

### Step 2: Copy Placement

Place copy from Stage 8 into wireframe layouts. The copy team delivered with clear hierarchy — designers map that hierarchy into appropriate layout components.

**Claude automation**:
- Assemble page structures from Relume components based on the sitemap
- Place copy into wireframe sections from the markdown files
- Generate per-page markdown content files ready for the AI native build pipeline
- Flag missing integration touchpoints by cross-referencing wireframes against the integration requirements map from Stage 4

### Step 3: Platform Export

Export paths differ by platform:
- **AI Native** — export as native React components
- **Webflow** — export into Webflow as a unified sitemap
- **Framer** — wireframes pulled from Relume into Figma, then into Framer

### Step 4: QA Review

Nick's team reviews to confirm:
- All integration touchpoints from the sitemap are accounted for
- Happy paths are represented (post-action pages, redirects)
- CMS sections are properly marked
- Form locations and embed placements are correct

## Handoff

Complete wireframes for all pages with copy placed, CMS sections marked, integration touchpoints visible. Ready for high-fidelity design or direct export to platform.

## Non-Negotiable Checklist

- [ ] Wireframes completed for every page in the sitemap
- [ ] Copy placed into all wireframe sections
- [ ] CMS-driven sections clearly marked
- [ ] Integration touchpoints visible (form locations, embed placements, dynamic content areas)
- [ ] Nick's team has reviewed and confirmed integration touchpoints are accounted for
- [ ] Happy paths represented in the wireframes (post-action pages, redirects)
- [ ] Wireframes exported or ready to export for the chosen platform
- [ ] Client has approved the wireframe structure
