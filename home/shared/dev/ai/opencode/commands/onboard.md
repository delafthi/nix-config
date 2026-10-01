---
description: Build concise project onboarding brief
agent: explore
subtask: false
---

# Onboard to a project

Analyze repository. Produce a concise onboarding brief for fast first
contribution. Focus on facts discoverable from files.

## Before You Start

Check for existing context:

- `CONTEXT.md` at root — domain terms and boundaries
- `docs/` — architecture decisions in the area of interest
- Component `README.md` or codedocs — patterns and decisions

Use established language. Don't re-litigate ADRs. Defer to any `AGENTS.md`
present at root. Do not duplicate instructions that skills already own.

## Workflow

1. Detect stack/runtime from root config files only: `flake.nix`,
   `justfile`, `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`,
   `Makefile`. Record presence, not assumptions.
2. Map top-level structure and true entry points (app, CLI, service, library
   exports). Cite file paths for every structural claim.
3. Read key docs (`README.md`, `CONTRIBUTING.md`, `AGENTS.md` if present).
   Capture required conventions. Mark unmentioned conventions as unknown.
4. Collect setup/build/run/test/lint/format commands from source of truth only
   (scripts, flake, justfile, Makefile, package.json scripts). No guessing.
5. Mark unknown values explicitly as `unknown` with a path or command output
   that failed to show them.
6. Note missing docs or setup gaps that would block a newcomer. Cite paths
   where evidence was checked.

## Parallelization (conditional)

- Main agent owns root-level analysis (repo shape, primary docs, top-level
  tooling).
- Subagents own module-level analysis when scope is broad (one module/package
  per subagent). Only split when justified by scope, not by default.
- Primary agent merges module findings into one brief. Deduplicate findings.
  Keep the brief as the single source of merged facts.

## Rules

- Evidence required: every fact in the brief must be traceable to a file path
  or command output. Do not invent architecture or directory purposes.
- Monorepo-aware: treat multi-package/module layouts as normal. Do not assume
  single root.
- Length: concise brief. If content exceeds ~35 lines, drop least specific
  facts first.
- Generality: procedure-based; no instance-specific narrative. Prefer
  project-specific facts over generic advice.
- Defer: do not restate jj or Nix syntax that skills already own. Reference
  them only if the repo enforces a non-standard constraint (and cite evidence).
- Read-only: use the preferred tools (`fd`, `rg`, `eza`) as available. No
  mutations. Do not create a PR or commit.

## Output format

Use this exact template. Fill only facts with evidence. If `AGENTS.md` exists,
follow it.

```md
# Project: <name>

Overview: <what project does, what problem it solves, why it exists>

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
