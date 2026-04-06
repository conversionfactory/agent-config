# Common AI Design Mistakes

These patterns immediately signal that a site was generated rather than designed. Avoid all of them.

## Typography

### Bold as Default
AI tools default to bold text everywhere. Bold is a tool for emphasis — when everything is bold, nothing is emphasized. Use regular weight for body copy, reserve bold for moments that earn it.

### No Secondary Text Color
Every heading and every body paragraph rendered in the same color and opacity. Designed sites use a softer treatment (lighter weight, reduced opacity, or a secondary color) for body copy to create hierarchy even within the same typeface.

### Flat Hierarchy
Headlines and body text too close in size. There's no "guitar solo" — everything plays at the same volume. The type should make it immediately clear what's most important.

### Missing Casing Variation
Everything in sentence case. Designed sites use uppercase for labels and metadata, sentence case for readability, sometimes all-lowercase for a casual feel. Casing is a design tool.

## Color

### Purple and Oversaturated Palettes
The default AI color palette skews toward purple, electric blue, and neon gradients. These aren't inherently bad, but they're chosen without emotional intention. Pick colors that mean something for the brand.

### Too Many Tints and Shades
Generating 10 stops per color when 5 will do (base + 2 shades + 2 tints). The extra gradations create decision fatigue and rarely get used.

### CTA Color Everywhere
Using the primary action color on icons, borders, backgrounds, and decorative elements. This dilutes its power. The CTA color should feel special when it appears on a button.

## Layout

### Banded Sections
Alternating white/gray/white backgrounds with hard edges. It's the path of least resistance, not good design. Use fades, cards, layout changes, or depth to create section transitions.

### Uniform Grids Everywhere
Every section is a 3-column grid with icons. Designed sites alternate between 1-col, 2-col, 3-col, and unexpected layouts to create rhythm and visual interest.

### Wireframe-First Thinking
Creating a layout template and then filling it with copy. The site should be built around the words — the designer's job is to give the copy emphasis, joy, and delight.

## Components

### Identical CTA Treatments
Primary and secondary buttons that look the same, especially on hover. They must feel distinct in every state — rest, hover, active, disabled.

### Same Icon for Different Concepts
Reusing a generic icon (like a checkmark or lightbulb) across multiple features. Each concept deserves a specifically chosen icon.

### Generic Screenshots
Dropping in raw product screenshots where a branded abstraction or styled mockup would be more appropriate. Screenshots can work, but they should feel intentional.

## Motion

### Motion for Motion's Sake
Every element fading in on scroll, parallax on everything, continuous looping animations. Motion should guide attention or invoke a feeling — if it doesn't do either, remove it.

### No Motion at All
The opposite extreme: a completely static page with no hover states, no transitions, no response to user interaction. At minimum, interactive elements should signal their interactivity.

## Craft

### No Optical Alignment
Buttons with icons using the same padding on all sides. The icon side needs ~75% of the base padding for optical balance.

### Eyeballed Nested Radii
Inner elements with the same border-radius as their container. The correct inner radius is `max(0, outer_radius - padding)`.

### Fixed Pixel Sizing
Font sizes and spacing in px instead of rem and clamp(). This breaks fluid responsive scaling.

### Mobile Fixes That Break Desktop
Changing base CSS values to fix mobile layout, when the fix should be an additive override at a smaller breakpoint. Desktop styles should never be touched when fixing mobile.
