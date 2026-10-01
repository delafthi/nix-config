---
description: Generate or update code documentation
agent: build
subtask: true
---

# Generate code documentation

Add or update docs for files in `$ARGUMENTS`; if empty, use files changed in
current working copy (`@`).

## Before You Start

Check for existing context:

- `CONTRIBUTING.md` — contribution guidelines and doc style
- `.editorconfig`, lint configs — formatting conventions
- `CONTEXT.md` at root — domain terms and boundaries
- `docs/` — architecture decisions in the area you're touching
- Component `README.md` or codedocs — patterns, decisions

Scope boundary:

- This command generates or updates code documentation (doc comments, API docs)
  in code files.

Do not assume repo stack, layout, or doc conventions. Only mirror what exists.
Use established language. Don't re-litigate ADRs. When prose reads like filler
or AI boilerplate, apply the `unslop` skill before writing it back.

## Workflow

1. Resolve target paths from `$ARGUMENTS`; expand directories to concrete files.
2. If no arguments, derive targets from current working-copy diff.
3. Read project doc guidance (`CONTRIBUTING.md`, `README.md`, language/style
   docs) and mirror existing style. Do not impose a preset generator style.
4. Read the implementation for each target before describing it. Verify behavior
   from code; do not infer unverified contracts.
5. Document only APIs consumed by users or other modules. Distinguish creating
   new docs from updating drifted docs.
6. Detect and fix stale documentation in touched files. When behavior
   contradicts existing text, update text to match code. Do not retain
   unverified claims.
7. Only describe properties the code enforces. Avoid restating trivial
   types/signatures without adding purpose, why, or invariants.

## Parallelization (conditional)

- If scope is larger than 2 files, split file set across subagents.
- Each subagent owns full doc pass for assigned files.
- Primary agent merges results and deduplicates repeated notes.

## What to document

- Public functions, classes, methods, modules
- Purpose, parameters, return values, thrown/raised errors
- Side effects and invariants when non-obvious
- Usage examples only when API intent is not obvious

## What to skip

- Trivial private helpers/getters/setters
- Generated/vendor code
- Redundant comments that restate code
- Speculative behavior not backed by code
- Behavior inferred without reading implementation
- Restating the signature/type without adding the why or invariants
- Boilerplate that duplicates the code's surface
- Documentation for internals not consumed outside the module unless
  `CONTRIBUTING.md` explicitly requires it

## Quality bar

- Concise language, no marketing text
- Terminology consistent with project; use project terms only when they exist
- Inline comments only for non-obvious logic
- Keep existing doc style (JSDoc, docstrings, rustdoc, godoc, etc.) based on
  file context, not a fixed choice
- Truthful to code; no unverified assumptions
- Apply the `unslop` skill to any prose written back to files when it shows
  filler or AI boilerplate, only where that skill's scope applies to file
  content

## Output consistency

- Return one final summary from primary agent only.
- Include: files updated, APIs documented, stale docs fixed, missing/unreadable
  paths.

Use this output shape:

```md
## Summary
- Scope: ...
- Actions: ...
- Missing/unreadable paths: ...

## Blockers
- <none|details>

## Result
- Files updated: ...
- APIs documented: ...
- Stale docs fixed: ...
```
