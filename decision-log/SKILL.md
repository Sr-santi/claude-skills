---
name: decision-log
description: Turn a batch of changes (commits, fixes, suggestions, options) into a decision page where the user marks each one Keep / Change / Revert (or picks among options), with before/after previews, adds a note, and copies the decisions back as a short block Claude then applies. Use after a session made several changes the user has not seen yet, when asked for a "change log to decide", "let me decide what stays", "keep or revert", "checklist of changes", or when several options need a pick and screenshots would make the choice easier. Also use when the user pastes back a block of lines starting with KEEP / CHANGE / REVERT.
---

# Decision log

One page per batch: each change is a row with what it did (numbers, not adjectives), where it lives, how to undo it, an optional preview, and a decision strip. The user decides on the page and pastes the decisions back; Claude applies them.

## Build the page

1. **List the items.** One per commit or per independent change. For each:
   - `ref`: short sha, PR number or option letter; `where`: branch, `#PR`, `local (worktree)`.
   - `status`: `local` (not pushed), `pushed`, or `proposed` (not made yet).
   - `title`: what the user sees change, in plain words.
   - `facts`: 1–3 lines, before → after with the measured number where there is one.
   - `files`: paths touched. `undo`: the exact command (`git revert <sha>`, `git reset --hard <sha>` for local-only, "drop the suggestion").
   - `preview` (optional, recommended for anything visible): see below.
   - `choices` (optional): defaults to Keep / Change / Revert; give option labels instead (e.g. `["A", "B", "Neither"]`) when the row is a pick between alternatives.
2. **Make previews** when the change is visible (UI, PDF, chart, layout) or when options differ in look:
   - Web UI: `node scripts/snap.mjs <url> <out.png> [--width 1440] [--full]`, run from a directory whose `node_modules` has `@playwright/test` (the script resolves it from the current directory).
   - Print/PDF: `node scripts/snap.mjs <url> <out.pdf> --pdf`, then rasterise pages: `python3 -c "import fitz,sys;d=fitz.open(sys.argv[1]);[p.get_pixmap(dpi=60).save(f'{sys.argv[2]}-p{i+1}.png') for i,p in enumerate(d)]" out.pdf out` (`pip install pymupdf` if missing).
   - Before/after: capture the parent commit and the change (`git stash`/second worktree, or the dev server before and after the edit). Same viewport, same data, same crop.
   - Keep images small: 60 dpi for PDF pages, crop UI to the region that changed. Previews are illustrations, not evidence; say what data they show (synthetic, local, prod read-only).
3. **Fill `template.html`:** copy it next to the images, set the title/lede/meta, replace the JSON in `<script id="data">`. Groups are free-form (`"Applied locally, not pushed"`, `"Already pushed"`, `"Options"`). Add a "Not done" list for what was left out on purpose.
4. **Check once:** screenshot the page (desktop and 390px wide), fix overlaps, then publish with the Artifact tool, passing the images through `files` (`{"img/before.png": "<path>"}`; `src` in the data uses the same relative path). Give the link in one line.

## Read the answer

The page copies a block like:

```
CHANGE 7343c091 (local (wt-229)) Print on white paper, cream on screen only
  note: cream ground should be preserved
KEEP afa1c65c (local (wt-229)) Long windows print in blocks of 10 periods
REVERT 653e2df0 (#229) ...
UNDECIDED ...
```

- **KEEP:** nothing to do.
- **CHANGE + note:** make the change the note asks for, as a new commit on top (don't rewrite pushed history); verify it the same way the original was verified (tests, re-render, re-measure) and show the new preview.
- **REVERT:** `git revert <sha>` (pushed) or drop the local commit; run the tests that covered it.
- **A / B / option label:** apply that option, discard the others.
- **UNDECIDED:** leave as is and list them at the end of the reply.
- Push only if the user asked; say what is local. Then republish the page with the new state (decided rows show their decision, new commits get rows) so it stays the record.

## Rules

- Facts only; every number states its source. No customer text or secrets in previews (crop or use synthetic data).
- A row the user can't judge without seeing it gets a preview; a row about internals doesn't need one.
- Decisions live in the viewer's browser (localStorage) only as a convenience; the pasted block is the record.
