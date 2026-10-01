---
name: debugging-and-error-investigation
description: Systematic root-cause debugging - build a feedback loop that goes red on the bug, then reproduce, minimise, rank hypotheses, instrument, and fix behind a regression guard. Use when a test fails, a build breaks, behaviour does not match expectations, or a bug is intermittent and will not reproduce on demand, even if the user never says "debug" and only pastes a stack trace, an error message, or "it only happens sometimes". Triggers on "why is this failing", "this test passed yesterday", "flaky test", "intermittent failure", "reproduce this bug", "works on my machine", and "crashes only under load".
---

# Debugging and Error Investigation

Find the cause, not a plausible patch. Skip phases only when explicitly
justified.

## Use When

- A test, build, or command fails
- Behaviour differs from what the user expected
- A bug is intermittent and does not reproduce on demand

## Don't Use When

- The cause is already known — fix it
- The user wants new behaviour — this is not feature work
- Work is changing what should happen, not restoring it

## Before You Start

Read the project's context first. These are files in the user's project, not in
this skill directory:

- `CONTEXT.md` at project root — domain terms and boundaries
- `docs/` — architecture decisions in the area you're touching
- The component's `README.md` or codedocs — patterns and decisions

Use the established vocabulary. A term that conflicts with `CONTEXT.md` means
the code or the user has drifted, not that `CONTEXT.md` is stale — surface it.

No `CONTEXT.md`? Note it and proceed. Never create one.

## Workflow

### 1. Shallow Investigation

Fast pass to understand the problem. Don't deep-dive yet.

- What changed? Recent changes, config, environment?
- What layer? Hardware, driver, middleware, application, build system?
- Where is it? File, function, method.
- What kind of issue? Memory, timing, concurrency, data, network, build?

Read relevant code and logs. Get a grasp of the problem domain.

### 2. Present to User

Before elaborate investigation, tell the user:

```md
Problem: <what's broken>
Where: <file/function/method>
Domain: <issue type — memory, timing, concurrency, etc.>
Approach: <what you want to do — A, then B, then C>
```

Wait for feedback. The user holds domain knowledge that re-ranks or dismisses
hypotheses instantly. This is a checkpoint, not an interview — if the request
was ambiguous about *what to build*, that is interview-me's job, not this one.

### 3. Build Feedback Loop

The discipline. Everything else is mechanical. A **tight** pass/fail signal for
the bug — one that goes red on *this* bug — finds the cause. Without one, no
amount of staring at code will.

Ways to construct one:

- Failing test at whatever seam reaches the bug
- CLI invocation with fixture input, diffing output against known-good
- Replay a captured trace through the code path in isolation
- Throwaway harness — minimal subset of system that exercises the bug path
- Bisection harness — automate boot at state X, check, repeat
- Differential loop — same input through old vs new version, diff outputs

**Tighten the loop:**

- Faster? Cache setup, skip unrelated init, narrow scope
- Sharper? Assert on specific symptom, not "didn't crash"
- More deterministic? Pin time, seed RNG, isolate filesystem

**Non-deterministic bugs:** Goal is a higher reproduction rate, not a clean
repro. Count it — run the loop in batches, record red/green.

Raise the rate before you reason:

- Shrink the window — smaller input, fewer records, shorter sleeps, faster clock
- Add pressure — parallelism, load, `--repeat`, scheduling churn
- Replay the same interleaving on a loop, not the test in isolation

The rate is a clue, not just an obstacle. Compare green-alone against
in-suite (and flat against climbing under load):

- Green alone, red in suite — cross-test pollution. Shared temp dir, DB rows,
  env var, port, leaked singleton. Find the writer, not the victim.
- Rate climbs with load or parallelism — shared mutable state under
  concurrency. Go to step 6, probe the boundaries.
- Rate flat under all of that — window is narrow, cause is not exotic.
  Instrument. Do not reason.

Zero red after `N` independent runs suggests the true rate is roughly below
`3/N` (a standard small-sample rule, like the one behind "test three times").
Treat that as a floor on what your loop can detect, not a fact about the bug.
If `N` runs still give zero reds, more runs of the same loop help less than
changing the workload.

**When you cannot build a loop:** Stop. List what you tried. Ask user for:
access to environment that reproduces it, a captured artifact, or permission to
add temporary instrumentation. Do **not** proceed to hypothesise without a loop.

### 4. Reproduce + Minimise

Run the loop. Watch it go red.

Confirm:

- Loop produces the failure mode **user** described — not a different failure
  nearby. Wrong bug = wrong fix.
- Failure is reproducible across runs (or high enough rate for
  non-deterministic)
- Exact symptom captured for later verification

**Minimise:** Shrink repro to smallest scenario that still goes red. Cut inputs,
callers, config, data, steps — one at a time, re-running loop after each. Keep
only load-bearing elements.

### 5. Hypothesise

Generate **3–5 ranked hypotheses** before testing any. Single-hypothesis
generation anchors on first plausible idea.

Each must be falsifiable:

> "If <X> is the cause, then <changing Y> will make the bug disappear /
> <changing Z> will make it worse."

If you can't state the prediction, it's a vibe — discard or sharpen.

### 6. Instrument

Each probe maps to a specific hypothesis. **Change one variable at a time.**

- Debugger/REPL first — one breakpoint beats ten logs
- Targeted logs at boundaries that distinguish hypotheses
- Never "log everything and grep"

Tag every debug log with unique prefix (e.g. `[DEBUG-abc1]`). Cleanup = single
grep.

### 7. Fix + Guard

Write regression test before fix — but only if a **correct seam** exists. A
correct seam exercises the real bug pattern at the call site. If no correct seam
exists, that itself is the finding — note it.

If seam exists:

1. Turn minimised repro into failing test at that seam
2. Watch it fail
3. Apply fix
4. Watch it pass
5. Re-run feedback loop against original scenario

### 8. Cleanup + Reflect

Before declaring done:

- Original repro no longer reproduces
- Regression test passes (or absence of seam documented)
- All debug instrumentation removed
- Throwaway prototypes deleted

**Then ask:** what would have prevented this? If the answer is a structural
change — a missing seam, a wrong module boundary — note it for the user; hand
the design work to the architecture-design skill rather than doing it here.
