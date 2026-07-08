---
name: architecture-design
description: Vocabulary for designing deep modules. Use when designing or improving module interfaces, finding deepening opportunities, or deciding where seams go.
---

# Architecture Design

Design deep modules: lots of behaviour behind a small interface, at a clean seam, testable through that interface.

## Use When

- Designing or refactoring a module interface
- Deciding where a seam belongs
- Finding shallow modules to deepen
- Making code more testable or AI-navigable

## Don't Use When

- Module is already deep and well-seamed
- User wants a quick fix, not a design pass
- Code is glue with no meaningful behaviour

## Before You Start

Check for existing context:

- `CONTEXT.md` at root — domain terms and boundaries
- `docs/` — architecture decisions in the area you're touching
- Component `README.md` or codedocs — patterns, decisions

Use established language. Don't re-litigate ADRs.

## Glossary

Use these terms exactly. Don't substitute "component," "service," "API," or "boundary."

- **Module** — anything with an interface and an implementation. Scale-agnostic: function, class, package, tier-spanning slice.
- **Interface** — everything a caller must know: type signature, invariants, ordering constraints, error modes, config, performance characteristics.
- **Implementation** — what's inside a module.
- **Depth** — leverage at the interface: behaviour exercised per unit of interface learned. Deep = lots of behaviour, small interface. Shallow = interface nearly as complex as implementation.
- **Seam** — where a module's interface lives. Where you can alter behaviour without editing in that place.
- **Adapter** — concrete thing that satisfies an interface at a seam. Role (what slot it fills), not substance.
- **Leverage** — callers get more capability per unit of interface. One implementation pays back across N call sites and M tests.
- **Locality** — maintainers get change, bugs, knowledge, verification concentrated in one place. Fix once, fixed everywhere.

## Deep vs shallow

Deep: small interface, lots of implementation.

```text
┌─────────────────────┐
│   Small Interface   │  ← Few methods, simple params
├─────────────────────┤
│                     │
│  Deep Implementation│  ← Complex logic hidden
│                     │
└─────────────────────┘
```

Shallow: large interface, little implementation. Avoid.

```text
┌─────────────────────────────────┐
│       Large Interface           │  ← Many methods, complex params
├─────────────────────────────────┤
│  Thin Implementation            │  ← Just passes through
└─────────────────────────────────┘
```

## Design Questions

- Can I reduce the number of methods?
- Can I simplify the parameters?
- Can I hide more complexity inside?

## Principles

- **Depth is property of interface, not implementation.** Deep module can have small, mockable internal parts — they aren't part of the interface.
- **Deletion test.** Delete the module. Complexity vanishes → pass-through. Complexity reappears across N callers → earning its keep.
- **Interface is the test surface.** If you want to test past the interface, module is wrong shape.
- **One adapter = hypothetical seam. Two adapters = real seam.** Don't introduce a seam unless something varies across it.
- **Single responsibility.** Module tracks one thing. Multiple concerns → split at seams between them.

## Testability

1. **Accept dependencies, don't create them.** `processOrder(order, paymentGateway)` good. `processOrder(order)` with `new StripeGateway()` inside — bad.
2. **Return results, don't produce side effects.** `calculateDiscount(cart): Discount` good. `applyDiscount(cart): void` mutating cart — bad.
3. **Small surface area.** Fewer methods = fewer tests. Fewer params = simpler setup.

## Going deeper

- **Deepening clusters** — see [DEEPENING.md](DEEPENING.md): dependency categories, seam discipline, replace-don't-layer testing.
