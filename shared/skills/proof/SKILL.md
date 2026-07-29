---
name: proof
description: Web-first skill for working with Proof documents via proofeditor.ai. Use when a Proof URL is shared, when creating collaborative docs in Proof, or when an installed Proof preference says new docs should live there.
---

# Proof

Proof is a collaborative markdown editor for agents and humans. Use the hosted web API at `https://www.proofeditor.ai`.

Every write must include `by: "ai:<agent-name>"` so Proof can track who wrote what.
Presence uses `X-Agent-Id: ai:<agent-name>` when joining a doc or posting presence. A bearer/share token authenticates document access. `by` records authorship.

## Default Behavior

If the user shares a Proof URL:
- Join the doc immediately.
- Show presence right away.
- Read the current state before editing.
- Work in the Proof doc unless the user explicitly asks you to move elsewhere.

When creating new docs, follow this priority order:
1. If persistent instructions already define a Proof default mode, use it.
2. Otherwise default to `collaborative_docs`.

Supported default modes:
- `all_new_markdown`: new markdown artifacts you create go to Proof by default.
- `collaborative_docs`: plans, specs, bug writeups, reports, memos, proposals, drafts, and similar iterative docs go to Proof by default.
- `explicit_only`: only use Proof when the user explicitly asks.

Boundary rules:
- Existing repo-tracked markdown files stay local unless the user explicitly asks to move or share them in Proof.
- Do not silently replace local project docs with Proof links.
- If the task is code-adjacent local documentation, keep it local unless the user asks for Proof.

## Shared URLs And Auth

Shared URL format:

```text
https://www.proofeditor.ai/d/<slug>?token=<token>
```

Use one of:
- `Authorization: Bearer <token>` (preferred)
- `x-share-token: <token>`
- `?token=<token>`

`by` controls authorship. `X-Agent-Id` controls presence identity. Bearer/share tokens authenticate document access.

## If Proof Looks Wrong

Use one reporting tool call:

```bash
curl -sS -X POST "https://www.proofeditor.ai/api/bridge/report_bug" \
  -H "Content-Type: application/json" \
  -d '{
    "summary":"Short bug summary",
    "context":"What you were trying to do and what looked wrong.",
    "slug":"<slug-if-you-have-it>",
    "evidence":[
      {
        "kind":"http_response",
        "method":"POST",
        "url":"https://www.proofeditor.ai/api/agent/<slug>/v3/edit",
        "status":500,
        "requestId":"<x-request-id>"
      }
    ]
  }'
```

If the response returns `status: "needs_more_info"`, ask the suggested questions and call the same endpoint again.

If you want reference code while debugging or preparing the report, you can optionally inspect:
- `https://github.com/EveryInc/proof-sdk`

## Existing Proof Docs

When a Proof URL is provided:
1. Extract `slug` and `token`.
2. Join immediately by posting presence with `X-Agent-Id`/`agentId`.
3. Read the doc with `GET /api/agent/<slug>/v3/document`.
4. Reply with a short confirmation like `Connected in Proof and ready.`
5. Then keep working inside Proof.

Read the document and show presence on join:

```bash
curl -sS "https://www.proofeditor.ai/api/agent/<slug>/v3/document" \
  -H "Authorization: Bearer <token>" \
  -H "X-Agent-Id: ai:<agent-name>"
```

Shared links also support content negotiation:

```bash
curl -sS -H "Accept: application/json" "https://www.proofeditor.ai/d/<slug>?token=<token>"
curl -sS -H "Accept: text/markdown" "https://www.proofeditor.ai/d/<slug>?token=<token>"
```

Update presence explicitly:

```bash
curl -sS -X POST "https://www.proofeditor.ai/api/agent/<slug>/presence" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -H "X-Agent-Id: <your-agent-id>" \
  -d '{
    "agentId":"<your-agent-id>",
    "status":"reading",
    "summary":"Joining the doc"
  }'
```

Presence identity can be supplied as `X-Agent-Id`, `agentId`, or `agent.id`. Prefer `X-Agent-Id: ai:<agent-name>`.

Common statuses: `reading`, `thinking`, `acting`, `waiting`, `completed`, `error`.

## Editing (v3)

The v3 surface is how you read and change a doc. Two endpoints, intent-level targets, no tokens, one
error shape:

- Read:  `GET /api/agent/<slug>/v3/document`
- Write: `POST /api/agent/<slug>/v3/edit`

Read everything in one call:

```bash
curl -sS "https://www.proofeditor.ai/api/agent/<slug>/v3/document" \
  -H "Authorization: Bearer <token>" -H "X-Agent-Id: ai:<agent-name>"
# -> { ok, revision, title, markdown, comments[], suggestions[] }
```

Change it in one call. Send an `operations` array; the server resolves targets against the live
document, so you never send a base token. `baseRevision` (an integer from the read) is optional —
include it only if you want a conflict guard. `Idempotency-Key` is optional.

```bash
curl -sS -X POST "https://www.proofeditor.ai/api/agent/<slug>/v3/edit" \
  -H "Content-Type: application/json" -H "Authorization: Bearer <token>" -H "X-Agent-Id: ai:<agent-name>" \
  -d '{"by":"ai:<agent-name>","operations":[
    {"op":"replace","find":"old visible text","with":"new text"},
    {"op":"insert","after":"heading:Background","markdown":"## Scope\n\nNew section."},
    {"op":"comment","on":"text to anchor on","body":"Is this still accurate?"}
  ]}'
# -> { ok:true, revision, markdown, comments[], suggestions[], applied, results[] }
```

Operations:
- `replace` — `{find, with}` (visible-text quote; `occurrence`/`before`/`after` to disambiguate)
- `insert` — `{after|before, markdown}` where the anchor is a quote, `heading:Title`, `section:Title` (before/after a whole section, subsections included), or `"start"`/`"end"`
- `delete` — `{find}`
- `set_document` — `{markdown}` (replace the whole doc; applied as a minimal diff, safe with live collaborators)
- `comment` — `{on, body, occurrence?}` · `reply` — `{comment, body, resolve?}` · `resolve`/`unresolve` — `{comment}`
- `suggest` — `{kind:"insert"|"delete"|"replace", find, with?, occurrence?}` (`with` required for `insert`/`replace`) · `accept`/`reject` — `{suggestion}`

`find` matches the visible text you see in `markdown`, not raw markdown syntax. If a `find`/anchor
matches **more than once**, the operation is rejected with `TARGET_AMBIGUOUS` and an
`error.candidates` list (each `{ occurrence, snippet }` showing the match in context) — **nothing is
changed**, never a silent first-match. Pick one with `occurrence` (`"first"`, `"last"`, or a 0-based
document-order index) or, for content ops, `before`/`after` context. This applies to
`replace`/`insert`/`delete` and to `comment`/`suggest` anchors alike. Multiple content ops apply
atomically; comments/suggestions apply in order. If a review op fails after content already committed,
the response is `ok:false` with `partial:true`, `applied`, and `results` — re-read and retry only the
failed op (a same `Idempotency-Key` safely replays). The response returns the post-edit document so you
can chain without re-reading.

Errors use one envelope: `{ ok:false, error:{ code, message, retryable, opIndex?, target?, candidates?, current? } }`. Codes:
`AUTH`, `NOT_FOUND`, `INVALID_REQUEST`, `TARGET_NOT_FOUND`, `TARGET_AMBIGUOUS`, `CONFLICT`,
`TOO_LARGE`, `BUSY`, `PENDING`, `INTERNAL`. If `retryable` is true, `error.current` carries the fresh
document so you can re-resolve and retry without an extra read. Rule of thumb: `retryable:false` →
fix the request; `retryable:true` with `current` → retry against `current`; `BUSY` → back off.

## Reading Comments

Read comment threads and suggestions from the same `v3/document` read:

```text
GET /api/agent/<slug>/v3/document  ->  comments[]  and  suggestions[]
```

- `comments[]` — each item has `id`, `quote`, `resolved`, `body`, and a chronological `messages[]`. The root comment is `messages[0]`; replies follow. A reply created with `resolve: true` carries `resolvedHere: true` on its message, while the top-level `resolved` reflects the thread's current state.
- `suggestions[]` — pending track-changes proposals, each `{ id, kind, quote, content, status }` where `kind` is `insert`, `delete`, or `replace`.
- Use a comment's `id` as the reply/resolve target (`reply`, `resolve`, `unresolve`).
- Use a suggestion's `id` as the accept/reject target.
- v3 review ops support resolving and unresolving comments; they do not support deleting comments.
- Use `/events/pending` or `/events/stream` to notice activity and decide when to re-read `v3/document`. Do not treat events as the source of comment text.
- `text.settled` is a sparse wake signal for normal text edits after collab persistence settles. Re-read `v3/document` before interpreting or editing; the event data intentionally includes hashes/revisions, not document content, and the actor is `system:collab`.

## Updating The Title

Use the title endpoint for document metadata:

```bash
curl -sS -X PUT "https://www.proofeditor.ai/api/documents/<slug>/title" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"title":"Updated document title"}'
```

Authenticate with `Authorization: Bearer <token>` or `x-share-token: <token>`.

## Deleting A Document

Only the document owner can delete a Proof doc. Use the owner credential returned at creation time, or a same-origin Every owner session in the browser:

```bash
curl -sS -X DELETE "https://www.proofeditor.ai/api/documents/<slug>" \
  -H "Authorization: Bearer <ownerSecret>"
```

Viewer, commenter, and editor share tokens cannot delete documents. Browser cookie based deletes require a strict same-origin request, so do not rely on tokenized viewer links or copied Library rows for deletion authority. A successful delete returns `shareState: "DELETED"` and later reads return deleted-document responses.

## Creating A New Proof Doc

Create a shared document:

```bash
curl -sS -X POST https://www.proofeditor.ai/share/markdown \
  -H "Content-Type: application/json" \
  -d '{"title":"My Document","markdown":"# Hello\n\nFirst draft."}'
```

Save:
- `slug`
- `accessToken`
- `ownerSecret`
- `shareUrl`
- `tokenUrl`
- `_links`

When Proof is the default for the task:
1. Create the doc.
2. Return the live Proof link to the user.
3. Join the doc immediately.
4. Keep working there.

## Events And Presence

Poll for pending events:

```bash
curl -sS "https://www.proofeditor.ai/api/agent/<slug>/events/pending?after=0" \
  -H "Authorization: Bearer <token>"
```

Subscribe to new live events:

```bash
curl -N "https://www.proofeditor.ai/api/agent/<slug>/events/stream" \
  -H "Authorization: Bearer <token>"
```

Only pass `after=<cursor>` or `Last-Event-ID: <cursor>` when you intentionally want replay. Without a cursor, the stream starts with new events created after connection.
Event frames include `id:`, `event: <type>`, and JSON `data:`. The stream sends heartbeat comments and closes periodically; planned closes include an id-only `event: cursor` frame so clients can reconnect with the last seen `id`.
`text.settled` means visible text changed through live collaboration and the persisted state has settled. Treat it as a prompt to re-read `v3/document` and decide whether to act; it does not carry the edited text.

Ack processed events:

```bash
curl -sS -X POST "https://www.proofeditor.ai/api/agent/<slug>/events/ack" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"upToId":123,"by":"ai:codex"}'
```

If you are staying in the loop while a human reviews changes, keep presence updated so the doc shows what you are doing.

## Error Handling

The v3 write endpoint returns one envelope: `{ ok:false, error:{ code, message, retryable, opIndex?, target?, candidates?, current? } }`.

| Code | Meaning | Action |
|---|---|---|
| `AUTH` | Bad or missing auth, or access revoked | Re-read the token from the URL and retry with a bearer token |
| `NOT_FOUND` | Slug not found | Verify the slug and environment |
| `INVALID_REQUEST` | Malformed body or unknown operation | Fix the request shape; do not retry as-is |
| `TARGET_NOT_FOUND` | A `find`/anchor quote did not match visible text | Re-resolve against `error.current` and use the exact visible text |
| `TARGET_AMBIGUOUS` | A quote matched more than once | Add `occurrence` or `before`/`after` context |
| `CONFLICT` | A targeted region changed under you | Re-resolve against `error.current` and retry |
| `TOO_LARGE` | Mutation exceeds the authoritative update fuse | Reduce or split the write before retrying (terminal for this payload) |
| `BUSY` | Authoritative base is settling | Back off briefly and retry |
| `PENDING` | Write committed; live convergence still settling (`202`) | Re-read `v3/document` to confirm |
| `INTERNAL` | Unexpected server error | Report it with raw evidence |

Guidelines:
- When `retryable` is true, the fresh document is in `error.current`; re-resolve your targets against it instead of issuing a separate read.
- If the behavior still looks wrong after a normal retry, call `POST /api/bridge/report_bug` with the request/response, request ID, slug, and a short context note.
- Include `by` on every write.
- Prefer markdown payloads as canonical text input.

## Discovery

- Discovery JSON: `https://www.proofeditor.ai/.well-known/agent.json`
- Docs: `https://www.proofeditor.ai/agent-docs`
- Setup: `https://www.proofeditor.ai/agent-setup`
- Report bug tool: `https://www.proofeditor.ai/api/bridge/report_bug`
- Open-source reference: `https://github.com/EveryInc/proof-sdk`
