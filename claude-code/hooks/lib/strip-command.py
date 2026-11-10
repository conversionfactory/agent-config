#!/usr/bin/env python3
"""Print a shell command with text that can't run as code removed.

Heredoc bodies are dropped and quoted strings are emptied, so a command that
only *mentions* `gh pr merge` (a PR body, a commit message, an echo) isn't
treated as a merge. Text that runs as code is kept: heredocs fed to a shell,
quoted strings after `bash -c` / `eval`, and double-quoted strings holding
`$(...)` or backticks. A quoted path after `cd` is kept
too, because the merge hooks need it to find the repo.
"""
import re
import sys

HEREDOC = re.compile(r"<<-?\s*(['\"]?)([A-Za-z_][A-Za-z0-9_]*)\1")
# A heredoc fed to a shell is code, not text: keep its body.
SHELL_HEREDOC = re.compile(r"(^|[;&|(]\s*|\s)(bash|sh|zsh|dash|ksh|source|\.|python3?|node|ruby|perl)(\s[^<]*)?<<")
# Quoted text that runs as code (`bash -c '...'`, `eval "..."`) or is a cd path.
KEEP_QUOTED = re.compile(r"(^|[\s;&|(])(cd|eval|-c)\s+$")


def split_heredocs(text):
    """Drop text heredoc bodies; swap code bodies for placeholders.

    Returns the text and the kept code bodies, so quote-emptying can skip them.
    """
    lines = text.split("\n")
    out, kept, i = [], [], 0
    while i < len(lines):
        line = lines[i]
        out.append(line)
        i += 1
        is_code = bool(SHELL_HEREDOC.search(line))
        for _, tag in HEREDOC.findall(line):
            # No terminator later on: not a real heredoc (e.g. `<<EOF` inside
            # quoted text), so don't swallow the lines after it.
            if not any(rest.strip() == tag for rest in lines[i:]):
                continue
            body = []
            while i < len(lines) and lines[i].strip() != tag:
                body.append(lines[i])
                i += 1
            i += 1
            if is_code:
                out.append(f"\x00{len(kept)}\x00")
                kept.append("\n".join(body))
    return "\n".join(out), kept


def empty_quotes(text):
    out, i, n = [], 0, len(text)
    while i < n:
        ch = text[i]
        if ch == "\\" and i + 1 < n:
            out.append(text[i:i + 2])
            i += 2
            continue
        if ch in "'\"":
            j = i + 1
            while j < n and text[j] != ch:
                j += 2 if ch == '"' and text[j] == "\\" else 1
            body = text[i + 1:j]
            # `$(...)` and backticks run even inside double quotes.
            runs = ch == '"' and ("$(" in body or "`" in body)
            keep = runs or KEEP_QUOTED.search("".join(out))
            out.append(text[i:j + 1] if keep else "''")
            i = j + 1
            continue
        out.append(ch)
        i += 1
    return "".join(out)


text, kept = split_heredocs(sys.stdin.read())
text = empty_quotes(text)
text = re.sub("\x00(\\d+)\x00", lambda m: kept[int(m.group(1))], text)
print(text)
