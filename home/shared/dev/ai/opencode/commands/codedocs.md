---
description: Generate or update code documentation
agent: build
subtask: true
---

# Generate code documentation

Add or update docs for files in `$ARGUMENTS`; if empty, use files changed in current working copy (`@`).

## Workflow

1. Resolve target paths from `$ARGUMENTS`; expand directories to concrete files.
2. If no arguments, derive targets from current working-copy diff.
3. Read project doc guidance (`CONTRIBUTING.md`, `README.md`, language/style docs) and mirror existing style.
4. Document only APIs consumed by users or other modules.
5. Keep docs behavior-accurate; fix stale docs found in touched files.

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

## Quality bar

- Concise language, no marketing text
- Terminology consistent with project
- Inline comments only for non-obvious logic
- Keep existing doc style (JSDoc, docstrings, rustdoc, godoc, etc.)

## Output consistency

- Return one final summary from primary agent only.
- Include: files updated, APIs documented, stale docs fixed, missing/unreadable paths.

Use this output shape:

```text
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
