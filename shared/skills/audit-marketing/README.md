# CF Product Marketing Audit Skill

A Claude Code skill (`/audit-marketing`) that runs the marketing-team portion of Conversion Factory's product marketing audit workflow end-to-end — from research and scoring to a Notion-ready final document. Design and web dev portions of the broader audit are scored separately by their respective teams.

## What the skill does

Given a client domain, the skill walks through three phases:

1. **INIT** — Pulls the client's website (homepage + key pages), saves raw HTML, builds a URL inventory from sitemap + nav + footer extraction, takes screenshots, queries Ahrefs for SEO data, checks social/community presence, reads any client-provided materials, and writes a research record.
2. **REVIEW** — Walks the auditor through all 17 scored sections in chat, one at a time. Each section presents findings + suggestions for confirmation before being written to the final document. Page-count verification steps for pages-heavy sections (Sales, Comparison, Resources) prevent the most common audit error: undercounting pages that don't follow obvious URL conventions.
3. **FINALIZE** — Runs keyword research and competitor SERP analysis, integrates a Loom transcript if recorded, runs a pre-finalize verification pass against the research data, prints the finished `final_output.md`.

The output is a Notion-ready Markdown file, written in second person to the client, in a register the audit presenter (typically Corey Haines at CF) can pick up and riff on while recording a Loom walkthrough.

## What gets scored

Seventeen sections covering positioning, customer research, homepage, sales pages, conversion pages, competitor comparison, resources, onboarding, email, sales material, messaging, pricing, CRO, GTM launches, ads, SEO, and internationalization. Each item is scored 0–5. Section-level scores roll up into a final rubric in Notion.

Design and web dev sections (Branding & Visual Design, Web Design, Web Technical) are scored separately by the design and web dev teams — this skill doesn't cover them.

## Setup

### 1. Install the skill

If your team syncs the `cf-skills` repo into `~/.claude/`, the skill is already available — invoke it with `/audit-marketing`. If you're installing it standalone, copy the `audit-marketing/` folder (containing `SKILL.md` and supporting files) into `~/.claude/skills/`.

### 2. Create your config file

Create `~/.claude/audit-config.env` with these values, edited for your machine:

```bash
# Where audit folders live for each client (one folder per audit)
AUDIT_BASE_DIR="$HOME/audits"

# Ahrefs API key (used for SEO data, competitor analysis, keyword research)
AHREFS_API_KEY="your_ahrefs_key_here"

# Path to the Ahrefs API reference doc (ahrefs_api_reference.md in this repo)
AHREFS_API_REFERENCE_PATH="/path/to/this/repo/ahrefs_api_reference.md"

# Path to finished example audits used as a tone reference during FINALIZE
AUDIT_EXAMPLES_PATH="/path/to/this/repo/examples"
```

This file is per-user and per-machine. The skill stays generic; you configure it once.

### 3. Confirm the API reference and examples

Two files in this repo are referenced by paths in `audit-config.env`:

- **`ahrefs_api_reference.md`** — A reference doc Claude reads at session start so it constructs Ahrefs calls correctly. Required for FINALIZE keyword research and competitor SERP steps.
- **`examples/`** — Finished client audits from prior CF engagements. Claude reads these during FINALIZE to match tone and structure. Optional but strongly recommended — the skill falls back to in-doc tone rules if the folder is missing.

## How to use it

### Starting a new audit

1. Drop any client-provided materials (positioning doc, competitor list, sales decks, customer research, free product account creds, etc.) into `{AUDIT_BASE_DIR}/{client-slug}/materials/`. You can add files later too — the skill picks them up at REVIEW.
2. Run `/audit-marketing client-domain.com` (e.g. `/audit-marketing nostra.ai`). The skill auto-detects whether this is a new audit or an in-progress one.
3. The skill will ask if you have preliminary info to paste, or you can say "go" to start research immediately.
4. INIT runs automatically. You'll get a summary of findings and any flags when it's done.

### Resuming an in-progress audit

Just run `/audit-marketing client-domain.com` again. The skill detects the existing folder and resumes from the last completed section.

### Section-by-section review

The skill presents each of the 17 sections in chat with a draft score and findings. For each one you can:

- Approve as-is ("good," "next")
- Adjust the score ("make it 3 instead")
- Add observations ("also mention X")
- Combine ("score should be 4 and add Y")

For Sales Pages (Section 4), Competitor Comparison (Section 6), and Resources (Section 7), the skill first shows you the page list it found and asks you to confirm or add to it before scoring. This is important — sitemaps often miss pages, and these sections depend on accurate counts.

### Finalizing

When all 17 sections are confirmed, say "finalize." If you recorded a Loom walking the client's site, paste the transcript first — the skill will integrate your live observations into the existing draft before printing.

The skill runs a pre-finalize verification pass that re-reads every absence/count claim and checks them against the research data. If anything can't be verified, it gets softened or flagged before printing.

The final `final_output.md` is saved to `{AUDIT_BASE_DIR}/{client-slug}/final_output.md`, ready to paste into Notion.

## File layout per audit

```
{AUDIT_BASE_DIR}/
└── client-slug/
    ├── materials/           # Client-provided files you drop in
    ├── html/                # Raw HTML of fetched pages (for grep verification)
    ├── screenshots/         # Page screenshots for visual scoring
    ├── research_data.md     # Research record + URL inventory (written once at INIT)
    └── final_output.md      # Notion-ready output (built progressively during REVIEW + FINALIZE)
```

## Roles this skill is written for

- **The auditor** — the person running `/audit-marketing`. Gathers research, walks the skill through scoring, edits the final notes. The skill addresses you as "you."
- **The audit presenter** — the senior who reads the notes on camera for the client-facing Loom. At CF this is typically Corey Haines. The notes are written so the presenter can pick up any bullet and riff on it live — skimmable bullets, not a script.

Even if you're doing both jobs, the notes are structured to support a hand-off.

## Where this skill fits in CF's broader audit workflow

1. Client fills out the preliminary info checklist (competitor list, positioning doc, sales decks, analytics access, free product account, etc.)
2. Auditor drops everything into `materials/` and runs `/audit-marketing`
3. Skill does research, walks scoring, finalizes the output
4. Auditor pastes `final_output.md` into Notion
5. Audit presenter reads the Notion page and records a 5–15 min Loom for the client
6. Design team and web dev team score their own sections separately

## Troubleshooting

**"AHREFS_API_KEY not set" at session start.** Check that `~/.claude/audit-config.env` exists and has the variable set. The skill sources this file at the start of every session.

**Ahrefs API reference is empty or shows a fallback message.** `AHREFS_API_REFERENCE_PATH` isn't pointing at `ahrefs_api_reference.md` in this repo. The skill will still run but Ahrefs steps may construct malformed calls — fix the path.

**Skill claims a page is missing that I know exists.** This usually means the page isn't in the sitemap *and* isn't linked from the homepage. Check `research_data.md` → `## URL Inventory` to see what the skill found. During REVIEW, you'll be prompted to confirm page lists for Sections 4, 6, and 7 — use that prompt to add anything missing.

**Skill gets stuck mid-review.** Run `/audit-marketing client-domain.com` again. The skill reads the progress marker at the top of `final_output.md` and resumes from the next unfinished section.

## Contributing

Improvements live in this repo. When you find something to fix or extend:

- Edit `SKILL.md` directly for skill behavior changes
- Add a finished audit to `examples/` to improve tone reference
- Update `ahrefs_api_reference.md` if Ahrefs changes their API

The skill is designed to evolve with real audit experience — every finished audit is a chance to refine the rubric, scoring rules, or output format.
