# Brand Implementation Checklist

Use this when building a site with a defined brand, or when reviewing a build for brand consistency.

## Color System

- [ ] All colors in the palette are defined as tokens (CSS custom properties, Tailwind config, or JSON)
- [ ] Every color has a defined role (CTA, background, text primary, text secondary, accent, border)
- [ ] CTA color appears only on conversion elements — not in decorative icons, borders, or backgrounds
- [ ] No more than 5 stops per color (base + 2 shades + 2 tints) unless the brand guide specifies otherwise
- [ ] All text/background combinations meet WCAG AA contrast minimums
- [ ] No hardcoded hex values that should reference tokens
- [ ] No colors in use that aren't in the brand palette

## Typography

- [ ] Only approved typefaces are loaded and used
- [ ] Each typeface has a defined role (headings, body, display/accent)
- [ ] Weight restrictions are respected (if a face is "Regular and Bold only," no other weights appear)
- [ ] Style restrictions are respected (if italic is reserved for one typeface, no other face uses it)
- [ ] Type scale follows a mathematical ratio (golden ratio preferred) with `clamp()` for fluid sizing
- [ ] All font sizes in rem, no fixed px values
- [ ] Heading line-height: 1.1-1.3
- [ ] Body line-height: 1.5-1.6
- [ ] No system fonts, monospace, or fallbacks visible in the UI

## Visual Motifs

- [ ] Brand-defined motifs (border styles, textures, patterns, graphic elements) are applied consistently
- [ ] No new motifs invented that aren't in the brand system
- [ ] Background textures connect to the brand narrative (not just decorative)
- [ ] Depth treatment matches brand personality (layered shadows vs. flat surfaces)

## Buttons and CTAs

- [ ] Primary CTA uses the designated CTA color
- [ ] Primary and secondary CTAs are visually distinct in all states (rest, hover, active, disabled)
- [ ] Icon-side padding on buttons is ~75% of base padding for optical alignment
- [ ] Button hover states feel intentional and match the brand's interaction style

## Spacing and Layout

- [ ] All spacing in rem
- [ ] `clamp()` used for fluid responsive sizing
- [ ] Horizontal page padding is percentage-based
- [ ] Nested border radii calculated: `inner_radius = max(0, outer_radius - padding)`
- [ ] Bullet/icon alignment uses `items-start` with manual top offset (not `items-center` when text wraps)

## Responsive

- [ ] Mobile overrides don't change desktop base values — only additive overrides at smaller breakpoints
- [ ] Brand identity is preserved at all viewport sizes (proportions, hierarchy, motifs still recognizable)

## Tokens and Documentation

- [ ] Design tokens exist in at least one format (CSS custom properties, Tailwind config, or JSON)
- [ ] Token names are semantic (describe the role: `--color-cta`, not the value: `--red-500`)
- [ ] Brand rules are documented in the project's CLAUDE.md or style guide for future reference
- [ ] Any weight, style, or usage restrictions are explicitly noted (not just the allowed values, but the prohibited ones)
