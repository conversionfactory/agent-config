---
name: creative-direction
description: "Stage 5: Creative Direction — translate brand strategy into a concrete visual direction with approved aesthetic. Use when developing stylescapes, hero concepts, or finalizing visual direction."
---

# Stage 5: Creative Direction

You are guiding a CF team member through the Creative Direction stage. This translates brand strategy into one approved visual direction that governs all downstream design and development.

## Context

**Goal**: Translate the brand strategy into a concrete visual direction — one approved aesthetic that the design team executes against for every downstream deliverable.

**Owner**: Zach's Team (Design)
**Supports**: Corey's Team (alignment check against positioning)
**Tools**: Figma (primary), Midjourney, Envato, FreePic, Icons8, ChatGPT, Claude (asset sources), Pangram Pangram, Google Fonts, Adobe Fonts (typefaces), Loom (client walkthrough)
**Prerequisites**: Stage 3 (Brand Strategy) or Stage 2 (Positioning) at minimum

## Workflow

Ask the user: **What client? Is this a Revolution/serious Evolution (stylescapes) or Evolution (hero section approach)?**

### Approach by Scope

**Revolution / Serious Evolution — Three Stylescapes**:
Built in Figma. These are NOT mood boards — they are the actual assets planned for use and expansion. Each concept covers:
- Color palette
- Typographic palette (primary/secondary heading typefaces)
- Visual style
- Layout direction
- Illustrations
- Icons
- Patterns
- Textures
- Photo styling

Presentation is intentionally expressive and free, not constrained by buildability. Sometimes clients want to see a concept applied to a specific deliverable (hero section, ad).

**Evolution — Hero Section Approach**:
Starts with the hero section rather than freeform stylescapes because existing elements (like logo or color palette) are being kept and built upon. May carry over color palette but add new graphics, typography, or texture.

### Typography Licensing Checkpoint

- Free typefaces vs. purchased licenses (Adobe, Pangram, other foundries)?
- Client budget for premium typefaces?
- Character and ligature support confirmed against target markets and languages identified in Stage 4

### Deliverable

One approved creative direction with all visual elements defined, delivered via Figma + Loom video walkthrough.

**Claude automation**:
- Generate CSS variable sets and Tailwind config from approved creative direction (colors, type scale, spacing) — ready for AI native builds immediately
- Prepare Relume component theming notes
- Flag font compatibility issues based on client's target markets
- Generate image assets via Midjourney prompts or Claude image generation

## Handoff

One approved creative direction with all visual elements defined. CSS variables / Tailwind config generated for AI native builds.

## Non-Negotiable Checklist

- [ ] Creative direction approved by client (one concept selected)
- [ ] Typography defined — primary and secondary typefaces with licensing confirmed
- [ ] Color palette finalized
- [ ] Visual style, illustration style, icon style, pattern/texture approach documented
- [ ] Photo styling direction defined
- [ ] Typeface character support verified against target languages (from Stage 4)
- [ ] Loom walkthrough video delivered to client
- [ ] CSS variables / Tailwind config generated (for AI native builds)
