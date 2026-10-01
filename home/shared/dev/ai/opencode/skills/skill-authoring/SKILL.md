---
name: skill-authoring
description: Review, write, and improve Agent Skills (SKILL.md files) for opencode. Use when creating a new skill, auditing or rewriting an existing SKILL.md, fixing a skill that does not trigger or triggers too often, trimming an overlong skill, moving content into references/ or scripts/, writing a skill description field, or setting up evals for a skill. Triggers on "skill", "SKILL.md", "agent skill", "improve this skill", "skill review", "skill too long", "skill not triggering", "skill description".
---

# Skill Authoring

A skill is a directory with a `SKILL.md`: YAML frontmatter (`name`, `description`) plus a Markdown body, and optional `references/`, `scripts/`, `assets/` directories. Agents load only `name` + `description` at startup, load the full body when the skill activates, and load bundled files only when the body tells them to.

This skill reviews and rewrites skills. It covers auditing an existing skill, writing a new one, and diagnosing why a skill fails to trigger.

## Pick the mode

| Situation | Mode | Start at |
|---|---|---|
| Existing skill is wrong, bloated, or misbehaving | Review and rewrite | Step 1, then Step 3 |
| Skill never activates, or activates wrongly | Trigger diagnosis | Step 1, then Step 5 |
| Skill runs but produces poor output | Output evaluation | Step 1, then Step 6 |
| New skill needed | Create from real expertise | Step 2 |

## Step 1: gather ground truth before judging

A review without evidence produces generic advice. Collect, in this order of value:

1. **The real task.** The work the skill exists for, done at least once in conversation. Note the steps that worked, the corrections the user had to make, and the project-specific facts the agent got wrong.
2. **Execution traces.** What the agent actually did when the skill was active. Wasted steps and abandoned approaches localize the bad instruction far better than the final output does.
3. **Existing artifacts.** Runbooks, schemas, API specs, review comments, incident reports, config files, patch history. These contain the edge cases and conventions that generic knowledge lacks.
4. **The skill itself.** `SKILL.md`, plus every file it references.

If the user asks for a review without providing any of this, ask for one real example of the task. Do not review from the text alone and call the result done.

## Step 2: create — ground the skill in expertise

The most common failure is generating a skill from general model knowledge. That yields vague filler ("handle errors appropriately", "follow best practices") instead of the specific patterns worth keeping.

Write the skill from source material: a completed task, a runbook, a schema, a failing incident. Ask for the missing pieces rather than inventing them.

Scope the skill as one coherent unit of work, comparable to one function. Too narrow forces several skills to load for one task; too broad activates imprecisely. Past roughly 500 lines, a skill usually contains two or three skills.

Set the body's shape before writing prose:

```markdown
---
name: my-skill
description: <what it does>. Use when <situations, with trigger phrases>.
---

# My Skill

One sentence: what this covers.

## When to use
- Concrete activation cases

## Core procedure
Numbered steps, defaults chosen, alternatives named briefly

## Gotchas
- Corrections the agent would otherwise make

## Output template (only if a fixed shape is required)
...
```

Full authoring guidance, including calibration, instruction patterns, and scripts: read [references/writing-guidance.md](references/writing-guidance.md).

## Step 3: review — run the linter, then read for substance

Run the linter first. It catches spec violations deterministically:

```bash
python3 ~/.config/opencode/skills/skill-authoring/scripts/check_skill.py <skill-dir>
```

It reports frontmatter violations, length limits, broken file references, reference chains deeper than one level, and missing tables of contents. Exit code 1 means at least one error.

Then read the skill yourself. Automated checks cannot judge any of the following:

| Check | Question |
|---|---|
| Value | Would the agent get this wrong without the skill? If not, cut it. |
| Redundancy | Does the body restate what the model already knows? |
| Calibration | Are fragile operations prescriptive and flexible ones explanatory? |
| Defaults | Is one approach clearly primary, or a menu of equals? |
| Generality | Does it teach a method, or only answer one instance? |
| Triggers | Are instructions stated as actions, not declarations of intent? |
| Coverage | Are the known corrections written down as gotchas? |
| Duplication | Does the same fact live in both body and a reference file? |
| Overlap | Does another installed skill already do this? |
| Dead weight | Which instructions were never followed in any trace? |

Report findings as a table: check, verdict, evidence, proposed change. Apply only changes the evidence supports; say so when a section is fine.

## Step 4: rewrite — cut before adding

Length is the common defect. Cut duplication, general knowledge, and instructions no trace ever used before adding anything new. If pass rates plateau while rules keep growing, the skill is over-constrained: remove instructions and check whether results hold.

Preserve gotchas in the body even when the skill grows. A reference file works for gotchas only when the trigger for loading it is obvious; non-obvious failures usually need to sit where the agent reads first.

Reference files one level deep from `SKILL.md`. A file reached through another reference may be read partially, so link every file directly from `SKILL.md` and give each reference file a table of contents once it passes 100 lines.

Say *when* to read each file: name the condition and the path in the same sentence. "Read `references/<topic>.md` when the API returns a non-200 status" works. "See references/ for details" names neither, and the agent skips it.

## Step 5: trigger diagnosis

A skill only helps if it activates. The description carries the entire burden of that decision.

Write about 20 eval queries, 8-10 positive and 8-10 negative, stored as JSON:

<!-- rumdl-disable MD013 -->
```json
[
  { "query": "realistic user prompt", "should_trigger": true },
  { "query": "near-miss prompt that needs something else", "should_trigger": false }
]
```
<!-- rumdl-enable MD013 -->

Positives vary in phrasing, explicitness, and detail. Negatives are near-misses sharing vocabulary with the skill, not obvious irrelevancies. Real prompts carry file paths, personal context, and typos.

Split them 60/40 into train and validation sets, shuffle once, and keep the split fixed. Run each query three times through `opencode run --format json` and look for a skill tool call:

```bash
opencode run --format json "$query" | jq -e 'any(.[]; .type == "tool.use")'
```

Model behavior is nondeterministic, so compare trigger rates across runs, not single results. Use only train-set failures to guide edits; validation decides whether the change generalized. When stalled, change the structure of the description rather than adding keywords lifted from failed queries.

Details on description wording and the full optimization loop: read [references/description-triggering.md](references/description-triggering.md).

## Step 6: output evaluation

When the skill triggers reliably but the work it produces is wrong or weak, evaluate outputs instead of descriptions.

Store 2-3 test cases in `evals/evals.json` with a prompt, an expected-output description, and input files. Run each case twice, once with the skill and once without it or against a snapshot of the previous version, using fresh subagents so no state leaks between runs. Grade each assertion PASS or FAIL with quoted evidence. Drop assertions that always pass in both configurations; they measure nothing.

Full workspace layout, assertion design, grading rules, and the iteration loop: read [references/evaluation.md](references/evaluation.md).

## Hard limits

| Item | Limit |
|---|---|
| `name` | 1-64 chars, `a-z0-9-`, no leading/trailing/double hyphen, matches directory name |
| `description` | 1-1024 chars, non-empty |
| `compatibility` | under 500 chars if present |
| `SKILL.md` body | under 500 lines, target 150-300 |
| Reference depth | one level from `SKILL.md` |
| Frontmatter | no XML angle brackets in `description` |

## Anti-patterns

- Description written in first person ("I can help you...") or as vague intent ("Helps with PDFs")
- Explaining what the agent already knows instead of what it would get wrong
- Equal menus of options with no default
- Rules that contradict each other or the platform defaults
- Instructions no execution trace ever justifies
- Reference chains and vague "see references/" pointers
- Duplicate facts in body and reference file
- Skill descriptions overfit to a handful of test queries
- One mega-skill past 500 lines where two focused skills would compose

## Bundled files

| File | Read it when |
|---|---|
| [references/writing-guidance.md](references/writing-guidance.md) | Writing or restructuring skill content, calibrating instructions, deciding what belongs in a script |
| [references/description-triggering.md](references/description-triggering.md) | Fixing triggering, writing descriptions, designing trigger eval queries |
| [references/evaluation.md](references/evaluation.md) | Testing output quality, writing assertions, comparing skill versions |
| `scripts/check_skill.py` | Always, first, before any manual review |