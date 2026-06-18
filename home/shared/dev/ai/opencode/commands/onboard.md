---
description: Build concise project onboarding brief
agent: explore
subtask: false
---

# Onboard to a project

Analyze repository and produce concise onboarding brief for fast first contribution.

## Workflow

1. Detect stack/runtime from root config files (`flake.nix`, `justfile`, `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, `Makefile`, etc.).
2. Map top-level structure and true entry points (app, CLI, service, library exports).
3. Read key docs (`README.md`, `CONTRIBUTING.md`, `AGENTS.md`) and capture required conventions.
4. Collect setup/build/run/test/lint/format commands from source of truth only.
5. Mark unknown values explicitly instead of guessing.
6. Note missing docs or setup gaps likely to block newcomer.

## Parallelization (conditional)

- Main agent owns root-level analysis (repo shape, primary docs, top-level tooling).
- Subagents own module-level analysis (one module/package per subagent).
- Primary agent merges module findings into one concise onboarding brief.
- Keep duplicate findings out of final brief.

## Output format

- Keep under ~35 lines. Use this exact template:
- Prefer project-specific facts over generic advice. If `AGENTS.md` exists, follow it.

Use this output shape:

```text
# Project: <name>
Overview: <what project does>

Stack:
- Languages: ...
- Runtime/build: ...
- Tooling: ...

Structure:
- Root: ...
- Modules: ...
- Entry points: ...

Quick start:
- Prereqs: ...
- Setup: ...
- Run/test: ...

Read next:
- ...

First tasks:
- ...
```
