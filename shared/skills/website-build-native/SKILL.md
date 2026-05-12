---
name: website-build-native
description: "Stage 10A: AI Native Website Build (Next.js) — design and development happen simultaneously with Claude Code, then integration wiring. Use when building a client site on the AI Native (Next.js) platform."
---

# Stage 10A: AI Native Website Build (Next.js)

You are guiding a CF team member through an AI Native website build. Design and development happen simultaneously in this workflow.

## Context

**Goal**: Build a high-fidelity, fully designed website where design and development happen simultaneously — then hand off to the engineering team for integration wiring.

**Prerequisites**: Stage 5 (Creative Direction) approved, Stage 8 (Website Copy) completed, Stage 9 (Wireframes) completed, Platform confirmed as AI Native in Stage 4

## Phase 1: Design & Aesthetic (Zach's Team)

**Owner**: Zach's Team (Design)
**Tools**: Figma (design), Claude Code (implementation), Relume (component foundation)

The design team works fluidly between Figma and Claude Code — same as the Figma-to-Framer workflow but with code output. Designers own the visual output.

**Claude automation**:
- Apply CSS variables / Tailwind config from Stage 5 (Creative Direction)
- Build responsive layouts from Relume component exports
- Implement design tokens (colors, typography, spacing) from the approved creative direction
- Generate React components matching Figma designs
- Handle responsive breakpoints (desktop, tablet, mobile)

### QA Checkpoints (Phase 1)
- Copy team reviews for message alignment
- Design team verifies implementation matches Figma vision
- Responsive QA at all breakpoints

## Phase 2: Integration & Wiring (Nick's Team)

**Owner**: Nick's Team
**Tools**: Claude Code, platform APIs, client's third-party tools

Takes the designed site and wires all integrations from the Stage 4 integration requirements map:
- Form submissions (HubSpot, Mailchimp, custom endpoints)
- Email capture and sequence triggers
- Analytics event tracking
- CMS connections
- Auth flows (if applicable)
- Third-party embeds
- Webhooks and external workflow triggers
- Happy path implementations (redirects, confirmation states)

**Claude automation**:
- Implement form handlers connected to client's ESP/CRM
- Set up analytics event tracking
- Wire CMS collections and dynamic content
- Build happy path flows (post-form redirects, confirmation pages)
- Cross-reference implementation against the integration requirements map — flag anything missing

## QA Hierarchy

1. Copy team reviews design team's work (message alignment)
2. Design team reviews dev team's work (visual accuracy)

## Non-Negotiable Checklist

- [ ] All pages built and responsive (desktop, tablet, mobile)
- [ ] Creative direction faithfully implemented (colors, typography, visual style)
- [ ] All copy placed and verified against Stage 8 deliverables
- [ ] CMS set up and populated
- [ ] All integrations wired per Stage 4 integration requirements map
- [ ] All happy paths implemented (post-form, post-signup, etc.)
- [ ] Analytics tracking implemented
- [ ] Copy team has reviewed for message alignment
- [ ] Design team has reviewed for visual accuracy
- [ ] Responsive QA passed at all breakpoints
