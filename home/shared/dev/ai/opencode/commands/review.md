---
description: Review files, current change, or PR
agent: plan
subtask: false
---

# Review code

Provide structured, evidence-based review for target from `$ARGUMENTS`.

## Target selection

Use this order:

1. If first token in `$ARGUMENTS` matches PR number (`123` or `#123`), use PR mode.
2. Else if `$ARGUMENTS` provided, treat tokens as file paths; review only those files.
3. Else review current Jujutsu change (`@`).

Rules:

- In PR mode, strip leading `#` before CLI usage.
- In PR mode, ignore extra non-flag tokens and report warning in output.
- In file mode, if path missing/unreadable, report as blocker and continue with valid paths.
- Never expand scope to full repository.
- Do not mutate code during review.

## PR mode

For PR review mode:

- Scope: review PR diff and metadata (title/description), focus on code impact.
- Use GitHub CLI to fetch PR title/body and full diff for the PR number.
- Base review on fetched PR description plus diff content.
- If external action policy blocks remote fetch, report blocker with ready command.

## Current change mode

- Review only working-copy diff (`jj diff --git -r @`).
- Do not review unchanged files.

## Parallelization (conditional)

- Use up to 4 subagents with independent lanes when scope is broad:
  - Lane A: security and auth/secrets/data handling
  - Lane B: correctness and core logic
  - Lane C: architecture/performance/maintainability
  - Lane D: tests/docs/style meaningful deviations
- Primary agent merges all lane results into one final report.

## Priority

Review in this order:

1. Security
2. Correctness
3. Performance
4. Maintainability
5. Testing
6. Documentation
7. Style (only meaningful deviations)

## Severity rubric

- `CRITICAL`: active exploit, data loss/corruption, auth bypass, or production outage likely
- `HIGH`: serious user/business impact with plausible path to trigger
- `MEDIUM`: correctness/maintainability risk with limited blast radius
- `LOW`: minor risk or narrow edge case
- `SUGGESTION`: improvement with no clear defect

## Evidence rule

For each issue, include:

- concrete location (`file:line`)
- why current code fails (condition/path)
- expected behavior vs actual behavior
- concise fix direction
- minimal verification step

Reject speculative findings without evidence from code or diff.

## Merge rules

- Deduplicate equivalent findings from multiple lanes.
- Resolve conflicts by stronger evidence and higher severity.
- If two findings share root cause, keep one issue and mention affected locations.
- Preserve priority ordering from highest risk to lowest.

## Per issue

- Severity: `CRITICAL | HIGH | MEDIUM | LOW | SUGGESTION`
- Confidence: `HIGH | MEDIUM | LOW`
- Category
- Location: `file:line`
- Problem
- Impact
- Fix
- Verification (test idea or command)

## Output format

- List highest-risk issues first.
- Deduplicate equivalent issues.
- Default cap: 10 detailed issues; summarize remainder briefly.
- If zero actionable issues, state: `No actionable issues found`.
- Keep feedback actionable, objective, concise.

Use this output shape:

```text
## Summary
- Total issues: X
- Main risks: ...

## Blockers
- <missing path / missing diff>

## Issues
- [SEVERITY][Confidence][Category] `path/to/file:line` - problem, impact, fix, verification

## Residual Risk
- <what was not fully validated>
```
