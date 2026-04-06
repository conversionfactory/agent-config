---
name: branding
description: "Implement and enforce a defined brand system in code — color roles, typography rules, visual motifs, and design tokens. Use when building any site with an established brand identity, reviewing brand consistency, or generating design tokens. Not for defining a brand from scratch."
---

# Branding

You are implementing a brand that has already been defined. Your job is to translate brand decisions into code faithfully — and to catch when something drifts from the brand system.

This skill is not for defining a brand from scratch. It's for making sure a defined brand shows up correctly in production.

## Before Touching Anything

**Read the brand system first.** Check these locations in order:

1. Project `CLAUDE.md` — often contains the full design system: colors, type rules, weight restrictions, component specs
2. `.claude/product-marketing-context.md` — positioning and voice context that informs visual tone
3. Style guide page in the codebase (e.g., `/style-guide`, `/brand`)
4. Tailwind config or CSS custom properties for existing token definitions
5. Figma links in the project docs

If none of these exist, stop and ask. Don't guess at brand decisions.

### Overrides

Every rule below is a default. You can override any of them — but state why. If you can't articulate the reason, the default stands.

---

## Color System

### Roles, Not Just Values

Every color in a brand palette has a job. Define colors by their role:

| Role | What it does | Example |
|------|-------------|---------|
| **CTA / Action** | Primary conversion color. Sacred — used sparingly outside of buttons and key actions | A single bold hue |
| **Background** | Surface colors for sections and containers. Can be the brand's most prominent color | Dark, light, or brand-colored surfaces |
| **Text primary** | Headlines and key content | Often near-black or near-white depending on surface |
| **Text secondary** | Body copy, supporting information. Softer than primary to create hierarchy | Reduced opacity or a softer shade |
| **Accent** | Decorative elements, highlights, badges. Supports without competing with CTA | Complementary or analogous hue |
| **Border / Divider** | Structure and separation. Subtle | Low-opacity variants of text or accent colors |

A color being prominent in the brand doesn't mean it's the text color. Blue can be a background color, not a text color. Red can be an accent, not a CTA. **Check the role before applying.**

### Palette Discipline

- **Five stops per color**: base + 2 shades + 2 tints. Not ten
- The 5-stop approach gives you enough range for hover states, disabled states, and surface variants without bloat
- If the brand guide specifies exact values, use those — don't interpolate your own tint/shade ramp

### CTA Color Protection

- The CTA color should appear on buttons and key conversion elements
- Minimize its appearance in icons, illustrations, decorative borders, and backgrounds
- The less it appears elsewhere, the more it commands attention where it matters
- If you need a colorful decorative element, reach for accent colors, not the CTA color

### Contrast Requirements

- Minimum WCAG AA contrast ratios for all text on all surfaces
- Test text colors against every background they'll appear on — especially on brand-colored surfaces where contrast isn't obvious
- When in doubt, check the project's CLAUDE.md for specific contrast rules (some brands define exact opacity values for text on colored backgrounds)

---

## Typography System

### Typeface Rules

Every brand defines which typefaces to use. Some also define how — and the "how" is just as important:

- **Weight restrictions**: A typeface might only be used in specific weights (e.g., "only Thin and Regular, never Bold")
- **Style restrictions**: Some brands reserve italic for a specific typeface — no italic on the sans-serif
- **Role assignments**: One face for headings, another for body, possibly a third for display/accent use
- **Prohibited faces**: No system fonts, no monospace, no fallbacks that break the aesthetic

Read the brand system for these restrictions. If a typeface is specified with weight restrictions, those are hard rules, not suggestions.

### Hierarchy Through Type

- Headlines and body copy should contrast, not compete — different typefaces, different weights, different sizes that make roles immediately clear
- Secondary text (captions, labels, metadata) gets a softer treatment: lighter weight, reduced opacity, or a secondary text color
- The type scale is a starting point. Visual hierarchy can override semantic hierarchy — an `h3` can be larger than an `h1` if the layout demands it

### Scale and Sizing

- Prefer mathematical type scales (golden ratio: 1.618) as a baseline
- Use `clamp()` for fluid responsive sizing — never fixed pixel values
- Heading line-height: 1.1-1.3. Body line-height: 1.5-1.6
- All sizes in rem (16px base)

---

## Visual Motifs and Brand Elements

### What Motifs Do

Visual motifs are the small, recurring elements that make a brand recognizable: a texture, a border style, a shadow treatment, a graphic pattern. They signal intentionality and delight.

### Implementing Motifs

- Motifs are defined in the brand system — don't invent new ones
- Apply them consistently: if the brand uses dashed borders as a decorative pattern, use them throughout, not just once
- Motifs should feel like a signature, not a gimmick
- Background textures and patterns serve the brand narrative (industrial feel, organic feel, technical feel) — they're not decoration for its own sake

### Light and Depth as Brand Expression

- Whether a brand uses shadows, glows, gradients, or stays flat is a brand decision
- Depth treatment should match the brand personality: tactile and elevated (juicy CTA buttons with layered shadows) vs. clean and minimal (flat surfaces with subtle borders)
- Light effects (glows, streaks, highlights) must connect to the brand story — not just look cool
- If the brand system defines specific shadow values or glow treatments, use them exactly

---

## Design Tokens

### Token Architecture

When generating or maintaining design tokens, use semantic naming that describes the role, not the value:

```css
/* Roles, not colors */
--color-cta: #c82035;
--color-cta-hover: #e04d60;
--color-bg-primary: #0d0c0c;
--color-bg-secondary: #1c1b1b;
--color-text-primary: rgba(255, 255, 255, 0.95);
--color-text-secondary: rgba(255, 255, 255, 0.60);
--color-accent: #0024ff;
--color-border: rgba(255, 255, 255, 0.10);

/* Not this */
--red-500: #c82035;
--black-900: #0d0c0c;
```

### Token Formats

Generate tokens in whatever format the project uses:
- **CSS custom properties** for vanilla CSS or general use
- **Tailwind config** (`theme.extend.colors`) for Tailwind projects
- **JSON** for design tool sync or cross-platform use

### Keeping Tokens in Sync

- Tokens are the source of truth — if a color appears in the code that isn't in the token system, it's a drift
- When the brand updates a value, update the token, not individual instances
- Flag hardcoded color values that should reference tokens instead

---

## Brand Consistency Checks

When reviewing code for brand adherence, check:

### Color
- [ ] CTA color only used on conversion elements (buttons, key links)
- [ ] Text colors match defined roles (primary, secondary, accent)
- [ ] No hardcoded color values that should reference tokens
- [ ] Contrast ratios meet minimums on all surfaces
- [ ] No colors used that aren't in the brand palette

### Typography
- [ ] Only approved typefaces in use
- [ ] Weight restrictions respected (no bold where only regular is allowed)
- [ ] Style restrictions respected (no italic on sans-serif if prohibited)
- [ ] Type scale is consistent and mathematical
- [ ] Secondary text has a distinct, softer treatment than primary

### Visual Motifs
- [ ] Defined motifs applied consistently (not just in one section)
- [ ] No invented motifs that aren't in the brand system
- [ ] Background textures and patterns match brand narrative
- [ ] Depth treatment (shadows, elevation) matches brand personality

### Craft
- [ ] Optical alignment on buttons with icons (~75% padding on icon side)
- [ ] Bullet alignment with first line of text, not vertical center
- [ ] Corner nesting calculated: `inner_radius = max(0, outer_radius - padding)`
- [ ] Spacing in rem, sizing with `clamp()`
- [ ] Hover states differentiated between primary and secondary elements

---

## When No Brand System Exists

If there's no defined brand — no CLAUDE.md design rules, no style guide, no tokens:

1. **Ask before assuming.** Don't pick colors, typefaces, or motifs on your own
2. Suggest establishing at minimum:
   - 2 typefaces with role assignments and weight restrictions
   - A color palette with roles defined (CTA, background, text primary/secondary, accent)
   - One or two visual motifs (border style, shadow treatment, texture)
3. Document whatever gets decided in the project's CLAUDE.md for future reference

---

## Related Skills

- **marketing-website-design**: The companion skill for layout, section rhythm, motion, and overall page design
- **brand-voice**: For the written side of brand consistency — tone, messaging, terminology
- **copywriting**: Copy informs design — read the copy before designing around it
- **web-design-guidelines**: For accessibility compliance alongside brand adherence
