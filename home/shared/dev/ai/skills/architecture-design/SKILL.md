---
name: architecture-design
description: Design deep modules - put behaviour behind a small interface at a clean seam, and name that design in consistent vocabulary. Use when designing or refactoring a module, class, or package interface, choosing where a seam belongs, finding shallow or pass-through modules to deepen, choosing between competing interface designs, or making code more testable. Triggers on "deep module", "shallow module", "seam", "leverage", "locality", "port and adapter", "design it twice", "where should this boundary go", "too many small functions", and "make this refactor cleaner", even when the user never says "architecture" and just asks for a refactor or a design review.
---

# Architecture Design

Design deep modules: lots of behaviour behind a small interface, at a clean
seam, testable through that interface.

## Use When

- Designing or refactoring a module, class, or package interface
- Deciding where a seam belongs
- Finding shallow or pass-through modules to deepen
- Choosing between competing interface designs
- Making code more testable or AI-navigable

## Don't Use When

- Module is already deep and well-seamed
- User wants a quick fix, not a design pass
- Code is glue with no meaningful behaviour

## Workflow

1. **Gather context.** Read the project's `CONTEXT.md` at repo root, `docs/`,
   component READMEs. Use established language. Don't re-litigate ADRs. No
   `CONTEXT.md`? Note it and proceed — never create one.
2. **Interview first, plan last.** Run interview-me to walk the design tree.
   The branches are the Design Questions below. Do not produce a plan while
   any question is still open — an early draft is waste.
3. **Generate the plan once.** When the frontier is empty and the user has
   confirmed shared understanding, write the plan in full in one turn: the
   module, its interface, what hides behind it, where the seam sits, the
   adapters, and the testing strategy.

## Design It Twice

When the user wants to explore alternative interfaces for a deepening
candidate, your first idea is unlikely to be the best. Spawn 3+ sub-agents in
parallel, each designing a **radically different** interface:

- Agent 1: "Minimize the interface — 1–3 entry points max. Maximise leverage
  per entry point."
- Agent 2: "Maximise flexibility — support many use cases and extension."
- Agent 3: "Optimise for the most common caller — make the default case
  trivial."
- Agent 4 (if applicable): "Design around ports & adapters for cross-seam
  dependencies."

Give each agent a technical brief: file paths, coupling details, dependency
category, what sits behind the seam. Read
[references/deepening.md](references/deepening.md) when classifying those
dependencies — it defines the categories and the seam discipline that follows
from each. Use this skill's vocabulary and the project's `CONTEXT.md` language
in every brief so all designs name things consistently. Each agent outputs:
interface (types, methods, params, invariants, error modes), a usage example,
what the implementation hides, dependency strategy and adapters, and
trade-offs.

Show the user a problem-space framing first (constraints, dependency
categories, a rough illustrative sketch — not a proposal), then run the
sub-agents while they read it. Present the designs one at a time, compare by
**depth**, **locality**, and **seam placement**, then recommend — including a
hybrid if elements from different designs combine well. Be opinionated: the
user wants a strong read, not a menu.

## Glossary

Use these terms exactly. Don't substitute "component," "service," "API," or
"boundary."

- **Module** — anything with an interface and an implementation. Scale-agnostic:
  function, class, package, tier-spanning slice.
- **Interface** — everything a caller must know: type signature, invariants,
  ordering constraints, error modes, config, performance characteristics.
- **Depth** — leverage at the interface: behaviour exercised per unit of
  interface learned. Deep = lots of behaviour, small interface.
- **Seam** — where a module's interface lives; the one place behaviour can be
  altered without editing in that place.
- **Adapter** — the slot a thing fills at a seam, not its substance.
- **Leverage** — callers get more capability per unit of interface. One
  implementation pays back across N call sites and M tests.
- **Locality** — change, bugs, and verification concentrate in one place. Fix
  once, fixed everywhere.

## Design Questions

These are the branches interview-me walks:

- **Scope** — can the method count or the parameter list shrink?
- **Depth** — can more complexity hide inside?
- **Seam** — where does the interface live?
- **Dependency category** — in-process, local-substitutable, remote-but-owned,
  or true external?
- **Adapters** — what concretely satisfies the interface, and how many?
- **Test surface** — which tests survive a deepen, which get deleted?

## Principles

- **Depth is a property of the interface, not the implementation.** A deep
  module can have small, mockable internal parts — they aren't part of the
  interface.
- **Deletion test.** Delete the module. Complexity vanishes → pass-through.
  Complexity reappears across N callers → earning its keep.
- **Interface is the test surface.** If you want to test past the interface,
  the module is the wrong shape.
- **One adapter = hypothetical seam. Two adapters = real seam.** Don't
  introduce a seam unless something varies across it.
