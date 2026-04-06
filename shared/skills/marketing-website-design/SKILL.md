---
name: marketing-website-design
description: "Design and build marketing websites with intention — typography hierarchy, color discipline, layout rhythm, purposeful motion, and craft details. Use when building or reviewing any marketing site, landing page, or product page. Enforces design principles that separate designed sites from assembled ones."
---

# Marketing Website Design

You are an expert design engineer building marketing websites. Your job is to make every decision serve the story and conversion. If you can't explain why something is there, it shouldn't be.

## Before Building

**Check for a project design system first:**
If the project's `CLAUDE.md`, style guide, or design tokens exist, read them before making any visual decision. Use those constraints and only deviate when you have a stated reason. If no design system exists, ask about brand, typography, and color before proceeding.

Also check for `.claude/product-marketing-context.md` — the copy and positioning inform every design decision. **The site is built around copy, not the other way around.** The designer's job is to take the words being said and give them proper emphasis, joy, and delight.

### Overrides

Every rule in this skill is a default, not a law. You can override any of them — but state why. If you can't articulate the reason, the default stands.

---

## Typography

Typography is architecture. It's the single most important tool for telling the user what matters, what's secondary, and what's connected.

### Hierarchy Is Everything

- There must be clear, visible distinction between headlines, body copy, and supporting text
- When type feels right, you instantly understand what information is most important just by looking at it
- Repeat typographic patterns throughout the site to signal structure: new sections, emphasis, correlation between elements

### Contrast, Not Competition

Choose typefaces that contrast with each other, not ones that compete.

- **Competition**: Arial and Satoshi in the same palette — too similar, creates tension with no payoff
- **Contrast**: A serif and a geometric sans, or a display face and a clean body face — each has a clear role
- Think of it like harmony in music. You don't play a drum solo and guitar solo at the same time. It should always be clear which typeface is leading and which is supporting

### Size Hierarchy: Math as a Starting Point, Not a Contract

- Prefer the golden ratio (1.618) for your type scale as a baseline
- But HTML tags are not visual contracts — an `h1` doesn't have to be the biggest text on the page
- Sometimes a vanity headline is your `h1` but rendered small, while an `h3` is visually massive because the layout demands it
- This is where the fun comes in: you have your Lego pieces (the type scale), and you decide how to mix and match them per section
- The type scale gives you order; breaking it intentionally gives you interest

### Weight and Emphasis

- Don't default to bold. Bold is a tool, not a starting point
- Body text weight should feel natural to read — often regular or book weight
- Reserve heavier weights for moments that earn emphasis
- Use lighter weights for supporting and secondary information

---

## Color

Color exists to guide conversion and get out of the way.

### The CTA Color Is Sacred

- Designate one color for your primary call to action
- Minimize that color's appearance in supporting graphics, icons, and decorative elements
- The less it appears elsewhere, the more powerful it is when it shows up on a button

### Palette Discipline

- You need five stops per color, not ten: **base + 2 shades + 2 tints**
- This gives you a useful dynamic range without the bloat of 10 gradations you'll never use
- Resist the AI default of generating huge tint/shade ramps

### Supporting Colors

- Supporting colors don't have to be neutral — they can be saturated and contextual
- But the CTA color remains protected regardless
- Bold vs. restrained palette is a brand decision, not a universal rule — it depends on what you want someone to feel

### CTA Color in Practice

- Primary CTA gets the designated CTA color at full strength
- Secondary CTAs must look and feel distinct from primary — different treatment on hover, different visual weight
- Even in hover states, primary and secondary should never converge to the same appearance

---

## Dark and Light Surfaces

### Avoid Banded Sections

Hard-edged alternating bands (white section, gray section, white section) are boring and trite. There are better ways to create contrast between sections:

- Fade or shift the background color gradually
- Transition text and background together into a dark mode for a section
- Use cards, depth, or layout changes to create visual breaks without horizontal lines

### When to Flip

A dark/light flip earns its place when:
- You need to signal a transition or change in content type
- You want to call attention to a specific section (like a CTA block)
- The narrative demands a shift in mood

The flip serves contrast and attention, not decoration.

---

## Light and Depth

### Depth as Dynamism

- Use shadows, elevation, and layering to add visual energy
- Unless the brand intentionally calls for flat and minimal — that's a valid choice, not a default
- Cards are useful for consolidating and grouping information — shadows help them feel elevated
- Grids and line work are alternatives to shadows for creating structure

### Shadows

- Use multi-layer shadow stacks (3-5 layers at increasing spread with decreasing opacity) for realistic depth
- Avoid single-layer `shadow-md` or `shadow-lg` — they look flat and generic
- A CTA button should feel juicy — like a piece of fruit or a jewel. Depth and shadow give it that tactile quality

### Light Effects

- Glows, gradients, and highlights must be tied to the brand story
- Ask: does this align with what I'm trying to make someone feel, or am I just filling space?
- Light becomes gratuitous when it's clearly not connected to a narrative
- When it's tied to a story (metallic sheen for an industrial brand, soft glow for a wellness product), it feels intentional

---

## Motion and Animation

### Micro-Interactions Over Scroll Animations

- Interactive motion (responds to user action) is more valuable than passive animation (plays on its own)
- Think video game UI: one element sits still, another gives you a visual cue that you can interact with it. That distinction is powerful on the web

### Catch and Release Attention

- Animations don't need to loop forever
- Catch attention, deliver the message, release
- Logo marquees, rotating testimonials, and looping hero animations should be evaluated: does this need to keep moving, or has it done its job?

### When Motion Earns Its Place

| Trigger | Value | Guidance |
|---------|-------|----------|
| **Hover/state change** | High | Signal interactivity and guide the user to act. Most valuable animation type |
| **Page load** | Medium | Hero animations can hold attention, but don't need to loop indefinitely |
| **Scroll** | Conditional | Must be tethered to story and emotional narrative. Not every element needs a scroll entrance |
| **Looping** | Low | Use sparingly. Background loops can feel like filler if they're not tied to brand story |

### Motion Without Intention Is Noise

- If the animation doesn't invoke a feeling or guide an action, remove it
- A mix works well: some elements are static anchors, some appear on scroll, some respond to hover
- The blend depends on what you're trying to make people feel — if you don't know the answer, you don't have the right answer for motion either

---

## Layout and Section Rhythm

### Every Section Exists in Context

- Never evaluate a section in isolation — it's always in relationship with what comes before and after
- If the previous section is a three-column grid, this section should use a different layout
- Alternate structures: 3-col, then 1-col, then 2-col, then something unexpected
- This is how you create differentiation without relying on color changes or dividers

### When a Section Feels Off

The usual culprits:
- Elements competing for attention — a vanity headline the same size as its supporting text
- Layout too repetitive compared to surrounding sections
- Too columned-out and uniform — no visual surprise

### Create Interest Through Inversion

- Take a three-column grid of text and make the body copy huge, spanning the full width
- Reduce a headline to be smaller than the body text in a section where the body is the star
- Challenge the expected hierarchy when it serves the story

### Directing the Eye

- Use patterns, emphasis, and recession to guide scanning
- Features with illustrations: alternate left-right-left-right for rhythm
- CTAs, heroes, testimonials, and feature sections each have different compositional goals — don't apply the same layout logic to all of them
- The amount of information in a section dictates the approach

### Whitespace and Density

- Consolidating information into fewer sections is powerful — don't spread thin content across many sections
- Whitespace is a tool for emphasis, not just "breathing room"
- If a section can be tighter and still scannable, make it tighter

---

## Imagery and Illustration

### Images Support Copy, Not the Other Way Around

- Imagery exists to reinforce the message — a feature screenshot shows the feature in action, not just fills space
- Background illustrations can function as texture and pattern rather than focal points
- If you'd put a screenshot somewhere, ask: could a more branded abstraction work instead?

### Small Motifs Add Delight

- Little illustrative touches (a motif, an unexpected graphic, a subtle pattern) signal that thought was put into the page
- They build brand recognition and attitude
- They're the cherry on top — not the sundae

### Don't Reuse the Same Icon

- Using the same icon to represent different concepts reads as lazy
- Each icon should be specifically chosen for what it represents
- Icon libraries are starting points, not the final answer

---

## Craft Details

These are the tells that separate a site that was *designed* from one that was *assembled*.

### Typography Craft
- Secondary text color: body copy should not be the exact same color as headings. Use opacity or a softer shade to create hierarchy even within the same typeface
- Letter casing as a design tool: uppercase for labels and tags, lowercase for a casual feel, sentence case for readability
- Heading leading: 1.1-1.3. Body leading: 1.5-1.6

### Optical Alignment
- Buttons with icons need different padding than buttons without — the icon side gets ~75% of the base padding for optical balance
- Bullets must align with the first line of their text, not the vertical center of wrapped text. Use `items-start` with a manual top offset, never `items-center` when text wraps
- Corner nesting: always calculate `inner_radius = max(0, outer_radius - padding)`. Never eyeball nested border radii

### Spacing
- All spacing in rem, never px in production
- Use `clamp()` for fluid responsive sizing — never fixed pixel font sizes
- Horizontal page padding: percentage-based (e.g., `px-[5%]`)
- Section vertical padding: fluid with `clamp()`

### Responsive
- Never let mobile fixes cascade upward to desktop. Keep desktop base values intact, add smaller-breakpoint overrides only
- Mobile-first in concept, but the base CSS classes represent the desktop design — use `max-*:` or smaller breakpoint variants to override down

### Hover States
- Primary and secondary CTAs must feel distinct on hover — different transitions, different visual treatment
- Footer links and navigation: secondary by default, primary on hover. Not everything can be a focal point
- Interactive elements should give a clear signal that they're interactive before the user clicks

### The Goal

Not perfection — better than it was. Sweat the details. Follow the through-line. Make it feel like intention and thought were behind every choice.

---

## Common AI Design Mistakes

Avoid these patterns — they're the fastest way to make a site look generated:

1. **Bold as default** — bold is a tool, not a starting point. Most body text should be regular weight
2. **Everything is a focal point** — if every element screams for attention, nothing gets it. Especially in footers and navigation
3. **Purple and oversaturated palettes** — pick colors with emotional intention, not because they look "techy"
4. **10 tints and shades per color** — you need 5. Base + 2 shades + 2 tints
5. **Identical CTA treatments** — primary and secondary buttons must look and feel different, even on hover
6. **Wireframe-first thinking** — the site should be built around the copy, not the other way around
7. **Generic screenshots** — use branded abstractions where possible
8. **Same icon everywhere** — different concepts deserve different icons
9. **Banded sections** — alternating gray/white bands are the path of least resistance, not good design
10. **Motion for motion's sake** — every animation should have a reason

---

## Related Skills

- **branding**: For implementing and adhering to a defined brand system
- **copywriting**: The copy comes first — use this skill to write it
- **page-cro**: For conversion optimization of existing pages
- **web-design-guidelines**: For accessibility and interface compliance
- **shadcn-ui**: For component-level implementation with Tailwind
