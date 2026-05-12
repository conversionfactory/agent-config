---
name: website-build-framer
description: "Stage 10C: Framer Website Build — designers own the full build process with dev support for integrations and technical SEO. Use when building a client site on Framer."
---

# Stage 10C: Framer Website Build

You are guiding a CF team member through a Framer website build. In Framer, design and code are one-to-one — designers handle the bulk of the build.

## Context

**Goal**: Build a high-fidelity site in Framer where designers own the full process, with dev support only for integrations and technical SEO.

**Owner**: Zach's Team (Design)
**Supports**: Nick's Team (integration support, technical SEO check)
**Tools**: Framer, Figma (assets flow from Relume -> Figma -> Framer), Relume (wireframe foundation), Claude Code (code components, integration logic)
**Prerequisites**: Stage 5 (Creative Direction) approved, Stage 8 (Website Copy) completed, Stage 9 (Wireframes) completed, Platform confirmed as Framer in Stage 4

## Workflow

### Build Process

1. Wireframes go from Relume into Figma, then into Framer
2. Designers work back and forth between Figma and Framer during the hi-fi build
3. Same fluid workflow as going between Figma and Claude Code on AI native
4. Dev team only involved for integration support and possibly CMS help
5. Designers can handle CMS since they know Webflow's CMS patterns and Framer is simpler

### Technical SEO Check

Framer doesn't make technical SEO as accessible as Webflow. Needs a specific check around:
- Page schema
- Proper HTML components and organization
- Meta tags and structured data
- Sitemap generation

### Integration Wiring

Nick's team wires integrations per the Stage 4 requirements map:
- Form submissions
- Email capture and sequences
- Analytics
- Third-party embeds
- Webhooks and happy paths

## QA Hierarchy

1. Copy team reviews design team's work (message alignment)
2. Design team reviews dev team's work (visual accuracy)

## Non-Negotiable Checklist

- [ ] Wireframes pulled from Relume into Figma
- [ ] All pages built in Framer
- [ ] Responsive QA passed — desktop, tablet, mobile
- [ ] CMS set up and populated
- [ ] Technical SEO check completed (page schema, HTML structure, meta tags)
- [ ] All integrations wired with Nick's team support
- [ ] Copy team has reviewed for message alignment
- [ ] Design team has done final review
