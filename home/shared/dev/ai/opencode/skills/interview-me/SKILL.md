---
name: interview-me
description: Pin down what the user actually wants before building - interview them in numbered rounds, then close with a restatement they confirm. Use when a request admits several valid interpretations, when the intended outcome is unclear, when the user names only how the result should feel, or when a caller hands over an open design tree. Triggers on "help me scope this", "what exactly are we building", "requirements unclear", "not sure what you want", "more than one way to do this", "ask me until you understand", "brainstorm the design first". Also use when the user never names the problem domain and only describes the outcome they want.
---

# Interview Me

## Use When

- Request admits several valid interpretations
- Confidence in the intended outcome is under ~70%
- User names how the result should feel, not the requirements
- A caller hands over an open design tree (architecture-design step 2)

## Don't Use When

- Request is concrete and unambiguous
- User says "just do it" or "don't ask"
- Shared understanding is already confirmed via restate
- Work restores behavior that used to work — that is
  debugging-and-error-investigation, which defers ambiguity back here

## Before You Start

These are files in the user's project, not in this skill directory:

- The project's `CONTEXT.md` at repo root — domain terms and boundaries
- `docs/` — architecture decision records
- The component's `README.md` or codedocs — patterns, decisions

Load what exists and use the established language. No `CONTEXT.md`? Note it and
proceed, and never create one. Terms the interview clarifies may become the
basis of one later.

## Workflow

Steer it. Push back, answer "I don't know" and mean it, reject questions
pitched below the fidelity needed, call out scope drift. Agreeing with every
recommendation is a failure: nothing got decided, and the result carries a
certainty it has not earned.

### 1. Evaluate confidence

State the guess up front:

```text
HYPOTHESIS: <what you think they want>
CONFIDENCE: ~<N>% — <what's missing>
```

Under ~70%: interview. Over ~90%: go straight to Restate. In between: ask the
current frontier once, then re-score.

### 2. Ask in rounds, not one at a time

Map the subject as a **design tree**: decisions with decisions hanging off
them. Each answer can unlock follow-ups. The **frontier** is every question
whose prerequisites are already settled — the only questions you can honestly
ask yet. A **round** is the whole frontier, asked in full. Batch the questions
in one turn; never drip one per turn.

- Number every question and attach your recommended answer, so the user can
  answer the round by number.
- Two questions share a round only if neither depends on the other. A question
  that hinges on an answer still open in this round belongs to a later round.
- After the user answers the round, recompute the frontier and ask the next.
  Later rounds must ask things earlier rounds could not have.

```text
**Q1 - <title>**: <question body — may be multiple paragraphs, incl. choices>

> Recommended: <your recommended answer>
```

Two rough edges to watch:

- The frontier is your judgment, not a computed graph. If you put two questions
  in one round and an answer later turns out to have changed the other, say so
  and reopen that branch in the next round.
- The `Recommended:` line sometimes argues against the question as worded —
  agreeing means answering "no" to the question. When that happens, tell the
  user to answer the recommendation and say so.

### 3. Facts vs decisions

Facts are your job, never the user's. When a frontier question needs a fact
from the environment (filesystem, code, docs), look it up or dispatch a
sub-agent — don't ask for anything you could find yourself. Don't block the
round on it: only the questions downstream of a running exploration wait.

Decisions are the user's — put each to them and wait. Never answer your own
questions.

### 4. Ungrillable questions → prototype

Some questions can't be answered by talking — how something should look or
feel, which of two layouts to ship. No amount of rephrasing settles them, and
grinding is where sessions balloon. When a frontier question is ungrillable,
stop the interview and build a throwaway version (prototype) for the user to
react to, then come back and answer in one line.

"I don't know" is a real answer — and usually a signal to prototype rather
than to guess.

### 5. Techniques, applied when phrasing a round

Use these to shape the questions:

- **Challenge established terms.** If a term conflicts with `CONTEXT.md`, call
  it out: "Your glossary defines 'X' as Y, but you seem to mean Z — which is
  it?"
- **Sharpen fuzzy language.** Vague or overloaded terms → propose a precise
  canonical one: "You're saying 'account' — do you mean the Customer or the
  User? Those are different things."
- **Probe convention-signaling.** Buzzwords ("scalable", "modern", "clean"):
  "If you didn't have to justify this to anyone, what would you actually
  want?"
- **Verify against code.** User states how something works — check the code
  agrees. Contradiction → surface it: "Your code cancels entire Orders, but
  you just said partial cancellation is possible — which is right?"
- **Propose.** Multiple valid approaches → present options with your
  recommendation; the `Recommended:` line is the slot. Don't force a single
  answer — present trade-offs so the user can choose.

If a guess was wrong, update the hypothesis and re-ask.

### 6. Restate

When the frontier is empty — every branch visited, nothing left silently
assumed — write back in the user's language:

```md
Here's what I now think you want:

- Outcome:      <one line>
- User:         <one line — who benefits>
- Why now:      <one line — what changed>
- Success:      <one line — how we know it worked>
- Constraint:   <one line — the binding limit>
- Out of scope: <one line — what we're explicitly not doing>
```

Never use the question tool. Wait for explicit yes.

### 7. Plan gate

The plan is produced only after the frontier is empty **and** the user has
confirmed shared understanding. Never write a plan mid-interview. An early
draft is waste — the answers would have rewritten it. If a caller (command,
skill) expects a plan, finish the interview first; the plan is the deliverable
of the final turn, not a running draft.

### 8. Record decisions

Only when the interview actually decided something. Ask where, do not assume:
component codedocs, `docs/adr/`, `CONTEXT.md`, or skip. Not every repo wants
docs and not every decision earns an ADR.

Write the ADR only when all three hold: hard to reverse, surprising without
context, the result of a real trade-off. Keep it to what was decided, the
alternatives considered, and why this one — value for another engineer, not a
transcript.

### 9. Stop

No question cap: some interviews need three questions, some fifty. Honour a
plain "wrap up" or "accept it as it stands". Hand off to the caller once the
restate is confirmed.

A session running very long usually means the scope was too big — break the
work up and interview the pieces.

After several rounds, still unable to predict the user's reaction to the next
three questions? Say so: "Something foundational is missing. Want to step
back?"

## It's Working If

- Question count stays high while round count stays low.
- The user disagrees with something at least once. A session with no pushback
  is a session they didn't need.
- The interview ends somewhere unexpected — a question surfaced a decision
  being made implicitly.
- At the end, the user could defend each choice to someone who wasn't there.
