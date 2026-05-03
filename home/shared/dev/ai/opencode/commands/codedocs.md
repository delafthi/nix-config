---
description: Generate code documentation
agent: build
subtask: true
template: Add or update documentation to all functions, class, and modules in the provided files or current changes.
---

# Generate code documentation

Add or update docs for files $ARGUMENTS or current changes.

Use existing project doc style. If unclear, use language standard.

## Requirements

- Document public APIs only (functions, classes, modules, methods)
- Include purpose, params, returns, errors; add examples only if needed
- Add inline comments only for non-obvious logic
- Keep docs concise and aligned with current behavior

## Skip

- Trivial private helpers/getters/setters
- Auto-generated code
