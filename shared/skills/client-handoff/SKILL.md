---
name: client-handoff
description: "Stage 11: Client Handoff & Training — ensure the client can independently manage, update, and maintain their website. Use when preparing training materials or documentation for client delivery."
---

# Stage 11: Client Handoff & Training

You are guiding a CF team member through the client handoff process. The goal is client independence — they should be able to manage their site without breaking anything.

## Context

**Goal**: Ensure the client can independently manage, update, and maintain their website without breaking anything.

**Owner**: Nick's Team (technical handoff) + Zach's Team (design/experience handoff)
**Supports**: PM (client communication), Corey's Team (content management guidance)
**Tools**: Loom (tutorial videos), Notion (documentation), Webflow Editor resources (for Webflow builds)

## Workflow

Ask the user: **What client? What platform (AI Native, Webflow, or Framer)?**

### Platform-Specific Handoff

**Webflow**:
- Webflow has native training resources
- Individual collections need custom walkthroughs
- Webflow Editor instructional video

**Framer**:
- Similar to Webflow but simpler CMS
- Custom walkthrough for content management

**AI Native (Next.js)**:
- More comprehensive handoff needed — clients are working with code repos
- Open questions being explored:
  - Notion or Slack-based interface for triggering changes
  - Internal CF tool built for clients
  - Teaching clients Claude Code with guardrails
  - Protecting the codebase against non-designer/non-developer changes

### Training Materials

**Claude automation**:
- Generate CMS management documentation per platform
- Create client-facing training guides covering:
  - How to manage content
  - How to use components
  - How to invite editors
  - CMS field usage and best practices
- Potentially power an internal tool that lets clients make content changes without touching code
- For AI native: generate deployment docs, env variable docs, and content management approach

## Handoff Deliverables

1. CMS training video(s)
2. Written documentation (Notion)
3. Platform-specific guides
4. Support contact information

## Non-Negotiable Checklist

- [ ] CMS training video(s) sent to client
- [ ] Documentation covering: how to manage content, how to use components, how to invite editors
- [ ] Client has confirmed they understand how to make basic content updates
- [ ] For Webflow: Webflow editor instructional video sent
- [ ] For AI native: handoff documentation covering deployment, env variables, and content management approach
- [ ] Client knows who to contact for support
