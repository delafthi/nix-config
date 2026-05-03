---
description: Create or update README.md
agent: build
subtask: true
template: Generate or improve the project's README.md.
---

# Create or update README.md

Generate or improve the project's README.md.

## Check

- Whether `README.md` exists
- Project metadata (`package.json`, `pyproject.toml`, `Cargo.toml`, etc.)
- Actual setup/run/test commands

## Approach

- If `README.md` exists: keep good structure, fix stale/broken/missing parts
- If missing: create minimal README
- Keep content aligned with current project behavior

## Recommended sections

- Title + short description
- Installation
- Usage
- Development (if contributor-focused)
- Configuration (if needed)
- License

Include only relevant sections. Keep examples runnable and concise.

## Rules

- Be factual; no marketing or placeholders
- Use code blocks for commands/examples
- Keep text minimal and readable
