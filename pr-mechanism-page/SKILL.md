---
name: pr-mechanism-page
description: Build a visual artifact page that explains the mechanism a PR or a stack of PRs proposes, compares it with external references, and backs it with local simulations on synthetic data (the PR's real code where possible), never touching staging or production. Use when asked to "understand the mechanism", "make an artifact to understand this PR", wants "plots and graphics before and after", "compare with external references", or "mock up measurements / dummy simulations" for a PR review.
---

# PR mechanism page

One page that lets a reviewer see what a change does, how it compares with published practice, and what running it shows. Local worked examples, when present, live in `examples/` and are not published; `used-in.local.md` records where each reference was used.

## Rules

- **Nothing official is touched.** No writes, no calls to staging or production services, no model calls with company keys. Simulations run locally: a container with `--network none`, in-memory fakes for REST/DB clients, scripted answers in place of models.
- **Real code, fake data.** Run the PR's own functions (SQL functions, pure Python/TS modules) on synthetic data. Reimplement only when the code can't run alone, and say so.
- **Label every number.** Each figure says whether it is simulated, synthetic or measured, and which parts are invented (shares, embeddings, model answers). A real measurement is read-only, aggregates only, and states its sample, source and date (the `measure-first` skill, when installed).
- **Facts only, short.** Plain sentences; numbers over adjectives; file:line for anything to fix. Findings that become PR comments follow the user's comment style and are posted only after the user approves.
- **No secrets** on the page or in scripts. No customer text: synthetic clients only ("Acme Loans").

## Steps

1. **Map the change.** List the PRs, their order (stack/base), migrations, status, and links to other repos. Fetch heads into a detached worktree in the scratchpad; never check out over the user's tree.
2. **Read the mechanism in the code,** not the PR body: constants, ordering rules, SQL functions, what is stored and what is dropped. Note the exact file:line for each piece you will show.
3. **Pick 3–6 mechanisms** that carry the design. For each, one external reference from `references.md`; search for a new one only when none fits, check it, then add it to `references.md`.
4. **Simulate each mechanism** with the smallest run that can show its behaviour or break it:
   - SQL/migrations: `scripts/sandbox_pg.sh up <files>` (applies each twice to check idempotency), feed synthetic rows through `scripts/sandbox_pg.sh sql`, call the real functions, `down` when done.
   - Python engine code: import the module, replace the REST/DB client and the model call with in-memory fakes and scripted answers (in-memory table that mirrors the SQL function it replaces).
   - TS rules: run the real function with `node_modules/.bin/tsx` on invented inputs .
   - Sample-size and noise questions: `scripts/power.py` (Monte Carlo + Wilson interval).
   - Edge cases worth one run: late or out-of-order data, "as of" dates, two writers at once, generic words in search, empty inputs, the cap the code sets.
5. **Write findings** as "What we saw" with the number. A behaviour that looks wrong gets one confirming run and a file:line.
6. **Build the page** from `template.html` (load `artifact-design` guidance through the Artifact quickstart first):
   - Header: lede + SIMULATED banner saying what ran, where, on what data.
   - **The mechanism:** one hand SVG loop/flow, PR number in each box, labelled arrows; then a PR table (adds / migration / status).
   - **One section per mechanism:** How · Reference · Simulation · What we saw, and a chart or real-output table.
   - **Before / after** pair when the change alters behaviour or UI (same axes, same scale, side by side).
   - **Against common practice** table: piece · author's choice · common practice · read (matches / differs / gap).
   - **What to ask the author:** numbered, file:line.
   - **How this was made** + what is not covered.
   - Interactivity only where it teaches (a slider for k or n, a toggle for before/after).
7. **Check once, publish.** `scripts/screenshot.sh page.html shot.png`, read the image, fix clipped labels and overlaps in one pass, then publish with the Artifact tool. In SVG, set colors through `fixVars` (presentation attributes don't resolve `var()`).
8. **Clean up and remember.** Remove the container and worktree when no longer needed. Save the page URL and the findings in a project memory for the PR. Add any new reference to `references.md`.

## Charts

Follow the `dataviz` skill: one axis, thin marks, direct labels for ≤ 4 series, a `<title>` on every mark for hover, text in ink tokens, accent for the series that matters, grey for the rest.
