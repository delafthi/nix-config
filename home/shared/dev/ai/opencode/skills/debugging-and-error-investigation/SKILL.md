---
name: debugging-and-error-investigation
description: Systematic root-cause debugging. Use when tests fail, builds break, or behavior doesn't match expectations.
---

# Debugging and Error Investigation

A discipline for hard bugs. Skip phases only when explicitly justified.

## Before You Start

Check for existing context:

- Domain docs — glossaries, protocol specs, API docs, architecture files
- `CONTEXT.md` at root — project-wide domain terms and boundaries
- `docs/` — architecture decisions in the area you're touching
- Component `README.md` or codedocs — patterns, decisions

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

Wait for feedback. User may have domain knowledge that re-ranks or dismisses hypotheses instantly. Cheap checkpoint, big time saver.

### 3. Build Feedback Loop

This is the discipline. Everything else is mechanical. If you have a **tight** pass/fail signal for the bug — one that goes red on *this* bug — you will find the cause. If you don't, no amount of
staring at code will save you.

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

**Non-deterministic bugs:** Goal is higher reproduction rate, not clean repro. Loop 100×, add stress, narrow timing windows. 50% flake is debuggable; 1% is not — keep raising rate.

**When you cannot build a loop:** Stop. List what you tried. Ask user for: access to environment that reproduces it, a captured artifact, or permission to add temporary instrumentation. Do **not**
proceed to hypothesise without a loop.

### 4. Reproduce + Minimise

Run the loop. Watch it go red.

Confirm:

- Loop produces the failure mode **user** described — not a different failure nearby. Wrong bug = wrong fix.
- Failure is reproducible across runs (or high enough rate for non-deterministic)
- Exact symptom captured for later verification

**Minimise:** Shrink repro to smallest scenario that still goes red. Cut inputs, callers, config, data, steps — one at a time, re-running loop after each. Keep only load-bearing elements.

### 5. Hypothesise

Generate **3–5 ranked hypotheses** before testing any. Single-hypothesis generation anchors on first plausible idea.

Each must be falsifiable:

> "If <X> is the cause, then <changing Y> will make the bug disappear / <changing Z> will make it worse."

If you can't state the prediction, it's a vibe — discard or sharpen.

### 6. Instrument

Each probe maps to a specific hypothesis. **Change one variable at a time.**

- Debugger/REPL first — one breakpoint beats ten logs
- Targeted logs at boundaries that distinguish hypotheses
- Never "log everything and grep"

Tag every debug log with unique prefix (e.g. `[DEBUG-abc1]`). Cleanup = single grep.

### 7. Fix + Guard

Write regression test before fix — but only if a **correct seam** exists. A correct seam exercises the real bug pattern at the call site. If no correct seam exists, that itself is the finding — note
it.

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

**Then ask:** what would have prevented this? If answer involves architectural change, note it for improvement.
