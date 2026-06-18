---
description: Create or update README.md
agent: build
subtask: true
---

# Create or update README.md

Generate or improve `README.md` based on verified project behavior.

## Workflow

1. Gather facts from source of truth: project manifests, scripts, task runners, and existing docs.
2. Verify setup/run/test commands from real config (do not invent commands).
3. Update existing README in place when possible; preserve good sections and headings.
4. If missing, create focused README with only relevant sections.
5. Keep examples minimal and executable.

## Recommended sections

- Title + one-line purpose
- Installation / Setup
- Usage
- Development (only if contributor workflows exist)
- Configuration (only if user-set options exist)
- License (if known)

## Quality bar

- Keep final README section order stable unless project has established order.
- Factual, concise, no marketing copy
- Commands/examples runnable and copy-paste safe
- Explain non-obvious prerequisites
- Remove stale instructions and dead links when found
- Prefer relative links for in-repo docs

## Output format

- Return short change summary: added, removed, and corrected sections.

Use this output shape:

```text
## Summary
- Scope: ...
- Actions: ...

## Blockers
- <none|details>

## Result
- Sections added: ...
- Sections corrected: ...
- Sections removed: ...
```
