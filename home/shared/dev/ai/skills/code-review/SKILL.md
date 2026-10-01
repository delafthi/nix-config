---
name: code-review
description: Run an evidence-based code review - dispatch lanes by file count, apply the read gate, the shape gate, the drop list, and the confidence rule, grade severity, merge duplicate findings, and write the summary, issues, and residual-risk report. Use when a review command loads this machinery, or when the user wants a review, an audit, or a second opinion on a diff, a file, a PR, or a working copy: "review this", "check my diff", "what is wrong with this", "is this ready to merge", "look over my changes", "find bugs in these files" - including when the user never says "review" and only asks what is broken.
---

# Code Review

The generic machinery of a review: the evidence rule, the severity rubric, the
lane threshold, merge discipline, the per-issue shape, and the report.

A caller loads this skill and supplies the rest: target selection, the lanes,
the domain deltas, and the report specifics that differ. A command file cannot
read a sibling command, which is why the shared part lives here and both
review commands load it instead of restating it.

This skill carries no knowledge about any language, subsystem, or standard.

## Use When

- A review command delegates its machinery here: `/review`, `/review-embedded`,
  or a later command that keeps the same evidence discipline.
- Findings from several lanes have to become one report.

## Don't Use When

- The work is applying a fix rather than collecting findings. The machinery
  ends at the report.
- The question is where a boundary belongs. That is architecture design, not
  evidence.

## What the caller supplies

- target selection, and the modes around it
- lane definitions and the lane count
- domain deltas: recalibrated severity triggers, extra per-issue fields, its own
  classes of unreadable code, its own drop-list items
- report specifics that differ: the zero-issue phrase, and any extra
  `## Summary` line

Everything else below is shared and must not be restated in the caller.

## Severity rubric

Five bands. The caller keeps the names and recalibrates the trigger text to its
domain.

- `CRITICAL`: active exploit, data loss or corruption, auth bypass, or
  production outage likely
- `HIGH`: serious user or business impact with a plausible path to trigger
- `MEDIUM`: correctness or maintainability risk with limited blast radius
- `LOW`: minor risk or a narrow edge case
- `SUGGESTION`: an improvement with no clear defect

Confidence is a separate axis: `HIGH | MEDIUM | LOW`.

## Evidence rule

Two gates. A finding passes both or it is not an issue.

Read gate: you opened the code at that location and can name what it says. A
line inferred from a diff hunk header, a filename, or recall is not read. Code
you could not open — generated, vendored, external, or absent from the tree —
is a `## Residual Risk` line, not an issue. A caller may extend that exclusion
with its own unreadable-code classes.

Shape gate: every issue carries all six.

- location `file:line`, inside the reviewed scope
- the condition or path where it fails, not "could be unsafe"
- expected vs actual, with actual observed in the code you read
- fix direction, one sentence
- verification: the command or test that would show it, labelled `run:` with
  its result, or `proposed:`. Never present `proposed:` as observed.

Do not file:

- anything that fails the read gate
- `Confidence: LOW` that reading did not raise
- style preferences the project's linter or `CONTRIBUTING.md` does not already
  flag
- praise, restated intent, or "consider adding tests" with no named gap

The confidence rule is a gate, not a hint. A LOW-confidence finding that reading
did not raise is not filed at any severity, and `Confidence: MEDIUM` is not a
licence to file something the read gate rejects.

When nothing survives the gates, say the caller's zero-issue phrase. That is a
complete result, not a failure.

## No cap, no padding

Do not cap the issue count. Every finding that survives both gates goes into the
report in full, and nothing real is demoted or shortened away to fit a limit.

The gates are the filter, not a count. A finding invented to fill a report fails
the read gate or lands on the drop list, so a cap would only hide how weak the
evidence was, and it would let a fabricated entry crowd a real one out of
view. Never invent an issue for the sake of one.

## Parallelization

Dispatch by file count, not by habit:

- Fewer than 4 changed files: one agent, every lane inline.
- 4 or more: one subagent per lane, at most the lane count the caller defines.
- Every lane returns findings in the `## Per issue` shape, each with a
  `file:line` it actually read.
- The primary agent merges, applies `## Merge rules`, and writes the report.
  One report, from the primary agent only.

## Merge rules

- Deduplicate equivalent findings from multiple lanes.
- Two findings, one root cause: one issue, every affected location listed.
- Conflicts resolve by stronger evidence, then higher severity.
- Multi-file scope groups by file, most severe file first.
- Where a caller defines an ordering within a file, that ordering breaks ties in
  the group, and severity breaks ties across groups.

## Per issue

- Severity: `CRITICAL | HIGH | MEDIUM | LOW | SUGGESTION`
- Confidence: `HIGH | MEDIUM | LOW`
- Category
- Location: `file:line`
- Problem
- Impact
- Fix
- Verification: `run: <command and result>` or `proposed: <test idea>`

A caller adds the fields its domain requires and reports them alongside these.

## Output format

- Number `I1`, `I2`, ... sequentially across the whole report, never per file.
- Multi-file scope: group under a file subtitle. Single file or single target:
  flat list.
- One line per issue, carrying the per-issue fields. No finding is trimmed to a
  summary line because the report is already long.

Use this output shape:

```md
## Summary
- Target: <what was reviewed>
- Critical: X
- High: X
- Medium: X
- Low: X
- Suggestion: X

## Blockers
- <none | missing path | missing diff>

## Issues
### <path/to/file>
I1. <band emoji> <category> - `<path/to/file>:<line>` <what fails, max 60 chars>
    Problem, impact, fix, verification. Confidence: HIGH
I2. ...

## Residual Risk
- <what was not fully validated>
```

When nothing survives the gates, `## Issues` is replaced by the caller's
zero-issue phrase, and the counts above it are zero.

## Not this command

This skill is machinery. The command that loads it owns the target, the lanes,
and the domain.

- `/review` — generic review of files, the current change, or a PR. Owns target
  selection and the four generic lanes.
- `/review-embedded` — C/C++ firmware review. Owns the MISRA and CERT tables,
  the firmware lanes, and the vendor-HAL exclusion from the read gate.
