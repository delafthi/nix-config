# Description and Triggering

The description is the only part of a skill an agent sees before deciding to
load it. Fixing triggering problems means rewriting descriptions and measuring
the result.

- [How triggering works](#how-triggering-works)
- [Writing the description](#writing-the-description)
- [Designing eval queries](#designing-eval-queries)
- [Running the eval](#running-the-eval)
- [Train and validation split](#train-and-validation-split)
- [The optimization loop](#the-optimization-loop)
- [Applying the result](#applying-the-result)
- [Overtriggering](#overtriggering)

## How triggering works

Three tiers load at different times:

| Tier | Content | When | Cost |
|---|---|---|---|
| 1 | `name` + `description` | Session start, all skills | ~50-100 tokens each |
| 2 | Full `SKILL.md` body | Skill activates | under 5000 tokens recommended |
| 3 | `references/`, `scripts/`, `assets/` | Body says to read them | Unlimited |

Because tier 3 loads on demand, moving material out of the body is free until
something needs it. Because tier 2 loads the whole body at once, body length is
paid on every activation.

Two consequences drive most fixes:

- Under-specified description: the agent never loads a skill that would have
  helped.
- Over-broad description: the agent loads a skill that adds cost and noise to
  unrelated work.

Agents also tend to skip skills for tasks they can already do with plain tools.
A one-line request needs no skill. Descriptions earn their keep on work
requiring knowledge beyond the model's defaults: unfamiliar APIs, domain
workflows, uncommon formats.

## Writing the description

Rules that hold across most skills:

- Say what the skill does and when to use it. Both halves.
- Frame it as an instruction to the agent: "Use when..." reads as an action
  condition, "This skill does..." reads as a label.
- Describe user intent, not internal mechanics. The agent matches what the user
  asked for.
- Write in the third person. First person, "I can help you...", mixes point of
  view in text injected into the system prompt.
- Be pushy. List the cases where the skill applies even when the user never
  names the domain: "even if they don't say 'CSV'".
- Include trigger phrases a user would actually type.
- Stay under 1024 characters. Descriptions grow during optimization, so check
  the limit every round.

```yaml
# Too vague
description: Helps with documents.

# First person
description: I can help you process spreadsheets.

# Usable
description: Analyze CSV, TSV, and Excel files - compute summary statistics,
  add derived columns, generate charts, and clean messy data. Use when the
  user has a data file and wants to explore, transform, or visualize it,
  even if they don't mention "CSV" or "analysis".
```

Add a `metadata.short-description` field only when the client asks for one.

## Designing eval queries

Roughly 20 queries: 8-10 that should trigger, 8-10 that should not.

<!-- rumdl-disable MD013 -->
```json
[
  { "query": "got a spreadsheet in ~/data/q4_results.xlsx, revenue in col C and expenses in col D - add a profit margin column and highlight anything under 10%", "should_trigger": true },
  { "query": "whats the quickest way to convert this json file to yaml", "should_trigger": false }
]
```
<!-- rumdl-enable MD013 -->

Vary the positives along four axes:

- Phrasing: formal, casual, typos, abbreviations.
- Explicitness: names the domain, or describes the need without naming it.
- Detail: terse against context-heavy, with paths and column names.
- Complexity: single-step against multi-step, including cases where the relevant
  part is buried in a larger chain.

The most informative positives are the ones where the connection is not obvious.
A query that already asks for exactly what the skill does triggers under any
reasonable description and tests nothing.

Make negatives near-misses. For a CSV analysis skill, "update the formulas in my
Excel budget spreadsheet" shares vocabulary but needs editing, not analysis. A
generic irrelevance like "write a fibonacci function" proves nothing.

Include realistic texture: file paths, personal context ("my manager asked"),
specific names and values, casual grammar.

## Running the eval

Check whether the agent loaded the skill, not whether it did the task well. For
opencode:

```bash
opencode run --format json "the query" 2>/dev/null \
  | jq -s -e 'any(.[]; .type == "tool_use" and .part.tool == "skill")'
```

Verify the tool event shape once against real output before trusting the filter;
event names differ across versions. If the client's JSON does not expose tool
calls, read the session log for skill references.

Model behavior is nondeterministic. Run each query three times, count
invocations, and compute a trigger rate. A should-trigger query passes above a
threshold, typically 0.5. A should-not-trigger query passes below it.

Twenty queries at three runs each is 60 invocations, so script the sweep and
parallelize it. Stop a run early once the agent has either loaded the skill or
started working without it.

## Train and validation split

Optimizing against every query produces a description tuned to those phrasings
and nothing else.

Split 60/40. Shuffle once, keep the split fixed across iterations. Both sets
keep a proportional mix of positives and negatives. Train drives edits;
validation is consulted only to judge whether a change generalized.

## The optimization loop

1. Evaluate the current description on both sets.
2. Read train-set failures only.
   - Positives missing: the description is too narrow. Broaden scope or add
     context.
   - Negatives firing: the description is too broad. Name what the skill does
     not do, or draw the boundary against the neighboring skill.
3. Rewrite. Generalize the cause rather than pasting keywords from failed
   queries, which is how overfitting enters. If several rounds fail to move the
   number, change the structure of the description instead of nudging wording.
   Recheck the character limit.
4. Repeat until train passes or improvement stalls.
5. Choose the iteration with the best validation rate. It is often not the last
   one; late iterations tend to overfit.

Five iterations is normally enough. When nothing improves, suspect the queries,
which may be too easy, too hard, or mislabeled, rather than the description.

## Applying the result

Update the frontmatter, confirm the character limit, then sanity check with 5-10
queries never used in optimization. Those give an honest read on generalization.

## Overtriggering

A skill that fires on unrelated work is not free. It spends body tokens, pushes
out user content, and can steer the agent away from the better default answer.

Causes and fixes:

- Adjacent skills with overlapping scope. Narrow both descriptions and state the
  boundary explicitly in each.
- A description phrased around a topic instead of a task. Describe the situation
  that calls for the skill, which is narrower than the topic.
- A catch-all verb in the description, "handle", "manage", "process". Replace
  with the concrete operations the skill performs.
- A skill that no longer matches its own body. When the body drifts, the
  description keeps firing on the old promise. Re-review the body and realign
  both.

Detect it with the negative half of the eval set. Near-miss negatives catch it
faster than reading.
