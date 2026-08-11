---
description: Scan a module or file for architecture deepening opportunities
agent: plan
subtask: true
---

# Improve module architecture

Find deepening opportunities in target from `$ARGUMENTS`. Use
architecture-design vocabulary. Drill into chosen candidate with interview-me.

## Target selection

**Scope before you scan — YAGNI.** Deepening a module pays off by making
future changes to it easier, so put extra weight on the parts that have
recently changed. Decide where to look before you look.

1. If `$ARGUMENTS` is a file path — use that file and its direct
   imports/exports.
2. If `$ARGUMENTS` is a module or class name — resolve to file(s) via grep/glob.
3. If `$ARGUMENTS` empty — walk a good stretch of history (`jj log --no-graph
   -r '::@'`) and inspect what recent changes touched (`jj diff -r <rev>
   --name-only` over the last few dozen changes) to find hot spots — files and
   areas that keep coming up. Let those paths pull your attention first. If
   changes are scattered with no clear hot spot, widen the net. Fall back to
   the working-copy diff (`@`) if still ambiguous.
4. If resolution fails — report blocker, stop.

## Before You Start

Check for existing context:

- `CONTEXT.md` at root — domain terms and boundaries
- `docs/` — architecture decisions in the area you're touching
- Component `README.md` or codedocs — patterns, decisions

Use established language. Don't re-litigate ADRs.

## Workflow

1. Read target and surrounding code. Apply architecture-design vocabulary, look
   for friction:
   - **Shallow modules** — interface nearly as complex as implementation
   - **Scattered logic** — one concept split across many small modules
   - **Leaking seams** — tightly-coupled modules crossing boundaries
   - **Untestable paths** — logic that can't be exercised through module's
     interface
   - **Pass-through modules** — deleting them moves code, doesn't concentrate it
2. Apply **deletion test**: would deleting this concentrate complexity, or just
   move it? "Yes, concentrates" is the signal.
3. Present candidates as markdown cards:

```md
### <Candidate name>

**Files:** `path/to/file.ts`, `path/to/other.ts`

**Problem:** <why current architecture causes friction>

**Solution:** <plain English description of what would change>

**Benefits:**
- Locality: <how change concentrates>
- Leverage: <what callers/tests gain>
- Testability: <how testing improves>

**Recommendation:** Strong | Worth exploring | Speculative
```

5. List candidates strongest-first. End with **Top recommendation**.
   Do NOT propose interfaces yet — the cards describe friction, not a design.
   The interface is settled by the interview that follows.
6. Ask: "Which of these would you like to explore?"
7. Use interview-me to walk the design tree — constraints, dependencies,
   deepened module shape, what sits behind the seam, what tests survive.

## Context updates

As decisions crystallize, keep context current — conservatively:

- **New term** not in `CONTEXT.md`? Note it. If load-bearing for domain, ask
  user whether to add it. Don't create `CONTEXT.md` proactively.
- **Fuzzy term sharpened**? Suggest update to `CONTEXT.md`. Wait for user
  confirmation.
- **User rejects with load-bearing reason?** Only if ADR criteria met (hard to
  reverse, surprising without context, real trade-off) — ask user where to
  record: `CONTEXT.md`, `docs/adr/`, component codedocs, or skip.

## Output format

All output is markdown, inline in the conversation. No external files unless
explicitly asked.

Use this output shape:

```md
## Summary
- Target: ...
- Candidates found: ...

## Candidates
### <name>
- Files: ...
- Problem: ...
- Solution: ...
- Benefits: locality, leverage, testability
- Recommendation: Strong | Worth exploring | Speculative

## Top recommendation
- <which and why>

## Blockers
- <none|details>
```
