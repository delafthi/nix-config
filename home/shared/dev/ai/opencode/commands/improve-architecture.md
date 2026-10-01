---
description: Find architecture deepening candidates in a module, file, or recent hot spot - shallow and pass-through modules, scattered logic, leaking seams, untestable paths. Read-only - returns a ranked candidate list, never a refactor. Use /review for plain defects.
agent: plan
subtask: true
---

# Improve module architecture

Find deepening opportunities in the target from `$ARGUMENTS`.

Read the `architecture-design` skill at
`skills/architecture-design/SKILL.md` for the glossary, the principles, the
design questions, the workflow, and the `Don't Use When` list. It owns the
method; do not restate it here. This command owns target selection, the
evidence gate, and the report.

Its `references/deepening.md` owns dependency classification and seam
discipline. Read it before classifying a boundary leak or naming a dependency
category.

This command never edits a file, never moves the working copy, never writes to
a change. It returns findings. The interface is settled later, with
interview-me.

## Target selection

**Scope before you scan — YAGNI.** Deepening a module pays off by making
future changes to it easier, so put extra weight on the parts that have
recently changed. Decide where to look before you look.

1. `$ARGUMENTS` is a file path — that file plus its direct importers and
   exports.
2. `$ARGUMENTS` is a module, class, or type name — resolve with `rg` to the
   defining file and its references, then narrow to the definition.
3. `$ARGUMENTS` is empty — find hot spots in history first:

   ```console
   jj log -r '::@' --limit 50 --stat --no-graph
   ```

   Paths that recur across those changes are the hot spots. Read the five
   highest-churn paths, not the whole tree. No hot spot? Say so under
   `## Blockers` and stop — a blind scan of the whole repo is not a scan.
4. Not a jj repo? `jj` reports `There is no jj repo in "."`. History is then
   unavailable — ask which paths to scan instead of guessing.
5. Resolution fails — list what you tried under `## Blockers` and stop.

Enumerate the scope before dispatching. Four lanes over an unlisted tree is
noise.

## Read gate

Two gates. A candidate passes both or it is not a candidate.

Read gate: you opened the module's interface and at least two of its call
sites, and can name the symbols at each. An interface inferred from a filename,
a line count, or recall is not read. Generated, vendored, or third-party code
you could not open is a `## Residual Risk` line, never a candidate.

Shape gate: every candidate carries all of `## Per candidate`.

## What counts as a candidate

Line count proves nothing. A large module can be deep; a small one can be
shallow. A candidate is real only when all four hold:

- **Interface cost** — what a caller must learn: the symbols, the invariants,
  the ordering constraints, the error modes. Name them from the code.
- **Leverage shortfall** — what the caller still does itself after the call.
  Cite the call site where it does it.
- **Deletion test** — delete it and complexity either vanishes or reappears
  across N callers. The skill's `## Principles` defines the test; apply it to
  the call sites you read, in your head, without editing.
- **Churn or coupling** — from history or from the call graph, not a vibe.

Reachable shapes, all named in the skill's `## Glossary` and
`## Design Questions`:

- **Shallow** — interface nearly as complex as the implementation behind it.
- **Pass-through** — deletion moves code instead of concentrating it.
- **Scattered** — one concept split across modules; callers must compose them
  in the right order every time.
- **Leaking seam** — a caller reaches past the interface into what should sit
  behind it. Cite the reaching call site.
- **Untestable path** — a test must reach past the interface to exercise the
  logic. Cite that test.
- **Boundary leak** — a dependency that should be an injected adapter is
  constructed inline at N call sites. Classify it with
  `skills/architecture-design/references/deepening.md` first; its category
  decides whether a port is warranted at all.

If the skill's `## Don't Use When` matches — the module is already deep and
well-seamed, the code is glue with no behaviour, or the user wants a quick fix
rather than a design pass — stop and use the zero-result line in
`## Output format`. That is a complete result, not a failure.

## Lanes (conditional)

- Fewer than 4 files in scope: one agent, no subagents.
- 4 or more: one subagent per lane, at most 4. Every lane reads the same
  enumerated scope.
  - Lane A — interface cost and leverage shortfall
  - Lane B — pass-through and scattered concepts
  - Lane C — leaking seams and boundary leaks
  - Lane D — untestable paths and test surface
- Every lane returns the `## Per candidate` shape, each carrying a `file:line`
  it opened.
- This agent merges, applies `## Merge rules`, and writes the report. One
  report. Lanes never report to the user.

## Merge rules

- Deduplicate candidates that name the same seam or the same spread of call
  sites.
- Two candidates, one root cause: one candidate, every affected location
  listed.
- Conflicts resolve by stronger evidence, then by more call sites affected.
- Rank by leverage lost, then by churn.

## Per candidate

- Files: `path/to/file:line` — the interface symbols and call sites you opened
- Depth shortfall: what the interface costs against what it hides
- Leverage lost: what callers do themselves, and at which call site
- Seam: where the interface would sit
- Dependency: `in-process | local-substitutable | remote-but-owned |
  true-external`, per `skills/architecture-design/references/deepening.md`
- Deletion test: complexity vanishes, or reappears across N callers
- Recommendation: `Strong | Worth exploring | Speculative`
- Confidence: `HIGH | MEDIUM | LOW`
- Verification: the `rg` command that shows the call-site spread, labelled
  `run:` with its result, or `proposed:`. Never present `proposed:` as
  observed.

## Recommendation bands

- `Strong` — deletion test concentrates, three or more call sites affected,
  and churn or a named bug lands in the seam. You read every location you
  name.
- `Worth exploring` — the gate passes on interface cost or on leverage
  shortfall, not both.
- `Speculative` — the gate rests on the deletion test alone, or on one call
  site. Say which.
- `Confidence: LOW` that reading did not raise is not filed.

## Not this command

Route elsewhere instead of filing:

- A plain defect — bug, race, leak, off-by-one, missing bounds check — is
  `/review`. This command has no severity bands and will not rank a defect
  against a structural finding.
- Embedded C/C++ anti-patterns — ISR context, MMIO, MISRA/CERT — are
  `/review-embedded`, which hands back here when a finding wants a seam rather
  than a lint fix.
- Code already deep and well-seamed. See the skill's `## Don't Use When`.

## Handoff

1. Rank candidates strongest-first and end with `## Top recommendation`. Be
   opinionated: one clear pick, not a menu.
2. Propose no interface, no types, no signatures. A card describes friction.
   The interface is settled in the interview that follows.
3. Ask "Which of these should we explore?" As a subtask, return the ranked
   list and that question to the caller; the parent agent puts it to the user.
4. Run interview-me on the chosen candidate only. Its workflow owns the design
   tree and its record-decisions step owns `CONTEXT.md` and ADR criteria. Do
   not restate them; the skill's `## Design Questions` lists the branches it
   walks.

## Gotchas

- `jj log --stat` reports the per-change file list in one call. Do not loop
  `jj diff -r <rev> --name-only` over dozens of revs.
- The read-only forms are allowlisted: `rg *`, `fd *`, `tokei *`, and the
  read-only `jj` forms the jj skill lists. Bare `jj` is not allowlisted, and
  neither is any mutating `jj` subcommand. Never run one from here.
- `fd` and `tokei` are the repo's file and metrics tools. Size is a tiebreaker
  at most, never evidence.
- A candidate naming a file you could not open goes to `## Residual Risk`.

## Output format

Markdown, inline in the conversation. No external files unless explicitly
asked. When nothing survives the gates: `No deepening candidates`.

```md
## Summary
- Target: <paths | <name> | hot spots from history>
- Files read: N
- Candidates: N

## Blockers
- <none | missing path | no hot spot | not a jj repo>

## Candidates
### <name>
- Files: `<path:line>`, `<path:line>`
- Depth shortfall: ...
- Leverage lost: ... at `<path:line>`
- Seam: ...
- Dependency: <category>
- Deletion test: complexity vanishes | reappears across N callers
- Recommendation: Strong | Worth exploring | Speculative
- Verification: run: <command> -> <result>

## Top recommendation
- <which, and the one reason>

## Residual Risk
- <code not opened, scope not scanned>
```
