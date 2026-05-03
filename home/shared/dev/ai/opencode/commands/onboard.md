---
description: Onboard to a project
agent: investigator
subtask: false
template: Analyze the project and provide a concise onboarding introduction to help get started quickly.
---

# Onboard to a project

Analyze the project and provide a concise onboarding introduction to help get started quickly.

## Check

- Build/runtime files: `flake.nix`, `justfile`, `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, `Makefile`
- VCS: `.jj/` or `.git/`
- Top-level structure and entry points
- Docs: `README.md`, `CONTRIBUTING.md`, `AGENTS.md`
- Common commands: setup, build, run, test, lint/format

## Output

Keep under ~30 lines. Use this shape:

```text
# Project: <name>

## Overview
<what project does>

## Stack
- Language(s):
- Build system:
- VCS:

## Structure
<top-level dirs + entry points>

## Quick Start
<prereqs + setup + core commands>

## Read Next
<key files/docs>

## Next Steps
<2-3 concrete actions>
```

Focus on actionable project-specific details. If `AGENTS.md` exists, follow it.
