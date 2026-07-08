---
name: interview-me
description: Drill down on what the user actually wants before building. Use when a feature request is ambiguous or underspecified.
---

# Interview Me

Clarify intent before building. Prevents building the wrong thing.

## Use When

- User asks for a feature that's underspecified
- Multiple valid interpretations exist
- You're less than 95% confident about what they want

## Don't Use When

- Request is concrete and unambiguous
- User explicitly says "just do it" or "don't ask"
- Already confirmed via restate

## Before You Start

Check for existing context:

- Domain docs — glossaries, protocol specs, API docs, architecture files
- `CONTEXT.md` at root — project-wide domain terms and boundaries
- `docs/` — architecture decision records
- Component `README.md` or codedocs — patterns, decisions

If context exists: load it. Use the established language.
If not: note it. Terms you clarify may form the basis of one later.

## Workflow

### 1. Evaluate Confidence

Read the request. Write one line: what do you think they want?

```text
HYPOTHESIS: <what you think they want>
CONFIDENCE: ~<N>% — <what's missing>
```

Confidence below ~70%: ask question.
Above ~90%: go to restate.

### 2. Ask One Question

Use the question tool. One question per turn. Always attach your guess.

If you get it wrong: update hypothesis, re-ask. Wrong guesses are productive — they narrow the space.

### 3. Challenge Established Terms

When user uses a term that conflicts with existing `CONTEXT.md` glossary, call it out immediately:

> "Your glossary defines 'X' as Y, but you seem to mean Z — which is it?"

### 4. Sharpen Fuzzy Language

When user uses vague or overloaded terms, propose a precise canonical term:

> "You're saying 'account' — do you mean the Customer or the User? Those are different things."

### 5. Probe Convention-Signaling

When user gives a vague or buzzwordy answer ("scalable", "modern", "clean"), probe:

> "If you didn't have to justify this to anyone, what would you actually want?"

### 6. Verify Against Code

When user states how something works, check whether the code agrees. If you find a contradiction, surface it:

> "Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"

### 7. Propose

When multiple valid approaches exist, present options with your recommendation:

```md
Options:
1. <approach A> — <pros/cons>
2. <approach B> — <pros/cons>
3. <approach C> — <pros/cons>

Recommended: <N> because <reason>
```

Don't force a single answer. Present trade-offs clearly so the user can choose.

### 8. Restate

When confident (~95%), write back in user's language:

```md
Here's what I now think you want:

- Outcome:      <one line>
- User:         <one line — who benefits>
- Why now:      <one line — what changed>
- Success:      <one line — how we know it worked>
- Constraint:   <one line — the binding limit>
- Out of scope: <one line — what we're explicitly not doing>
```

Use the question tool to confirm. Wait for explicit yes.

### 9. Record Decision (If Appropriate)

If the conversation produced decisions worth recording:

- Ask user where to document: component codedocs, `docs/adr/`, or skip
- Don't assume — not every repo needs docs, not every decision needs an ADR
- If recorded, focus on: what was decided, alternatives considered, why this choice
- Keep it targeted — value for other engineers, not info dump

Only create ADR when:

1. Hard to reverse
2. Surprising without context
3. Result of real trade-off

### 10. Stop

Test: can you predict the user's reaction to the next three questions?

If yes → shared understanding. Stop.
If no after several rounds → tell user: "Something foundational is missing. Want to step back?"
