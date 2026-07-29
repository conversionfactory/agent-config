---
name: copycraft
description: Copy editing overlay workflow — watch for pending requests, generate variations, apply chosen copy
invocation: /copycraft
---

# Copycraft Skill

This skill manages the copycraft copy editing workflow. It watches for text selections from the browser overlay, generates variations using Claude, and applies the chosen copy to source files.

## What this skill does

1. Checks if the copycraft MCP server is running (port 4242)
2. Starts it if needed
3. Guides the user to select text in the browser
4. Watches `get_pending_requests()` in a loop
5. For each new request: finds the text in source files, generates 3 variations, calls `submit_variations()`
6. When user applies a variation: edits the source file with `apply_variation()`

## Instructions for Claude

When the user runs `/copycraft`, follow these steps:

### Step 0 — Onboarding check (first time only)

Check if `.copycraft/team.json` exists in the project root:
```bash
cat .copycraft/team.json 2>/dev/null || echo "NOT_FOUND"
```

If the file does **not** exist, pause and tell the user:
> "Before we start, let's set up your team so all your review sessions are trackable in one place. Run this once:
>
> `create_team('Your Agency Name')`
>
> This gives you a dashboard at `https://relay-sigma-vert.vercel.app/dashboard?teamKey=YOUR_KEY` where you (and teammates) can see every client session and mark them as processed."

Then call `create_team` with a sensible default name based on the project directory name, or ask the user what to name their team. Once created, the key is saved automatically to `.copycraft/team.json` — they won't be asked again.

If the file **does** exist, skip this step silently.

### Step 1 — Verify MCP server is running

Check if port 4242 is listening:
```bash
curl -s http://localhost:4242/variations/test 2>&1 | head -5
```

If the server is not running, start it:
```bash
cd /path/to/copycraft && npm run start --workspace=packages/mcp-server &
```

Or if installed globally, just run:
```bash
node /path/to/copycraft/packages/mcp-server/dist/index.js &
```

Tell the user: "The copycraft server is running on port 4242."

### Step 2 — Guide the user

Tell the user:
> "Open your browser and navigate to your Next.js dev server. You'll see an **✏️ Edit Copy** button in the bottom-right corner. Click it to enter select mode, then click on any text you want to improve."

### Step 3 — Poll for pending requests

Use `get_pending_requests()` in a polling loop. Check every few seconds. When a new request appears:

1. Note the `requestId`, `text`, and `sourceHint`
2. Search the project source files for the exact text string:
   - Use grep/ripgrep to find which file(s) contain the text
   - Note the file path and line number
3. Generate 3 copy variations. Consider:
   - **Concise**: Shorter, punchier version
   - **Action-focused**: Starts with a strong verb, emphasizes benefit
   - **Conversational**: More human, friendly tone
4. Call `submit_variations(requestId, variations)` with all 3

### Step 4 — Wait for apply signal

After submitting variations, the user will see them in the browser overlay and can:
- **Preview**: Swaps text in the DOM temporarily
- **Apply to file**: Triggers a POST to `/apply/:id`

Poll `get_pending_requests()` again — when the request disappears (appliedIndex is set), or call `apply_variation()` is triggered, read the result to get:
- `originalText`: what to find in the source file
- `chosenVariation.text`: what to replace it with
- `sourceHint`: which component it came from (for narrowing the search)

### Step 5 — Edit the source file

Use your Edit tool to replace the original text with the chosen variation in the source file. Be precise — match the exact string in context.

After editing, tell the user which file was updated and what changed.

### Step 6 — Continue

Go back to Step 3 and keep watching for new requests. The user can keep selecting text and you'll keep generating variations.

## Tips

- The `sourceHint` field contains a component name, data-testid, or CSS selector hint — use it to narrow your file search
- If the text appears in multiple files, show the user the candidates and ask which one
- When editing JSX, be careful to preserve JSX expressions — only replace the literal text parts
- Commit the changes with a descriptive message like "copycraft: update hero headline for clarity"
