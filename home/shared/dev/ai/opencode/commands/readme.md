---
description: Create or update README.md, verifying every command it documents
agent: build
subtask: true
---

# Create or update README.md

Write or repair `README.md` so a stranger reaches a working first contribution.
Two READMEs nobody asked for is a defect.

## Before You Start

Check for existing context:

- `CONTEXT.md` at root — domain terms and boundaries
- `docs/` — architecture decisions in the area you're touching
- Component `README.md` or codedocs — patterns, decisions
- `README.md` itself, when one exists — section order and tone to preserve

Use established language. Don't re-litigate ADRs.

## Audit first

The audit decides create or update. Run it before writing.

1. Classify the target. The class picks the sections, and only that.
   - Library: install, usage, API surface, link to the published artifact
   - Application: prerequisites, install, run, configure
   - Monorepo root: what is here, which package to start with, how to build
     the workspace. No second README for a package.
2. Read `README.md` if present. It is evidence, not truth.
3. Read the real commands from the task runner, manifest, and CI config:
   `flake.nix`, `justfile`, `Makefile`, `package.json` scripts,
   `Cargo.toml`, `pyproject.toml`, `go.mod`.
4. Label every existing claim verified, stale, or unsupported.

## Truthfulness

This is the whole job.

- Every command you write or keep is executed first, with its result
  reported. No execution, no claim.
- A command that cannot run here (network, secrets, hardware) is reported
  unverified, sourced to the file that declares it.
- Prerequisites, version bounds, and platform limits come from the manifest or
  the CI matrix, never from memory.
- Take values from the source of truth: command names from the task runner,
  ports and paths from the config, host and default branch from the remote
  listing.
- Prefer a missing section over a wrong one. A visible gap beats a claim the
  reader cannot check.

## Do not generate

- A features section that restates the package description
- A license claim. Quote the license file or link it. With no license file,
  report that instead of naming MIT or anything else.
- A contributing section pointing at `CONTRIBUTING.md`, an issue tracker, or a
  code of conduct the repo does not contain
- Badges, coverage numbers, or build status not read from a config or a live
  endpoint
- Support, roadmap, sponsors, acknowledgements nobody asked for
- A README for a subdirectory when only the root one was requested

Every link and badge resolves or does not ship.

## Update mode

Fix or delete each stale and unsupported claim. Keep the existing section order
unless the project established another. Rewrite a section only when a corrected
claim requires it; keep surrounding prose that is still true. A section the
source of truth cannot back does not get filled in, it gets removed.

## Budget

Aim under 120 lines of content. When over, cut in this order:

1. Badges, table of contents, images
2. Restatements of the purpose line
3. Usage examples past the shortest working one
4. Configuration tables the defaults already state
5. Background prose the code does not require

Keep to the end: the purpose line, verified install steps, one working usage
example, the license pointer. Never cut a section carrying a verified command
to save lines. Cut a verbose one carrying none first.

## Quality bar

- Commands and examples runnable and copy-paste safe
- In-repo links relative
- Non-obvious prerequisites stated once, where the reader meets them
- No marketing copy, no emoji, no unfilled placeholder
- Sentence case headings, matching an existing README where one exists
- When prose reads like filler or AI boilerplate, apply the `unslop` skill
  before writing it back

## Output format

Return a short change summary. Do not paste the README.

Use this output shape:

```md
## Summary
- Scope: <library | application | monorepo root>
- Mode: <create | update>
- Actions: ...

## Blockers
- <none|details>

## Result
- Sections added: ...
- Sections corrected: ...
- Sections removed: ...
- Commands verified: <command> — <result>
- Commands unverified: <command> — why, and the file declaring it
```
