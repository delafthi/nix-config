# Evaluating Skill Output

Use this when the skill triggers correctly but produces work that is wrong, weak, or inconsistent. Descriptions fix triggering; only evaluating output quality fixes results.

- [Test cases](#test-cases)
- [Running with a baseline](#running-with-a-baseline)
- [Workspace layout](#workspace-layout)
- [Assertions](#assertions)
- [Grading](#grading)
- [Benchmarking](#benchmarking)
- [Reading the patterns](#reading-the-patterns)
- [Iterating](#iterating)
- [When to stop](#when-to-stop)

- [Test cases](#test-cases)
- [Running with a baseline](#running-with-a-baseline)
- [Workspace layout](#workspace-layout)
- [Assertions](#assertions)
- [Grading](#grading)
- [Benchmarking](#benchmarking)
- [Reading the patterns](#reading-the-patterns)
- [Iterating](#iterating)
- [When to stop](#when-to-stop)

## Test cases

A case has three parts: a realistic prompt, a human-readable description of success, and optional input files.

Store them in `evals/evals.json` inside the skill directory.

<!-- rumdl-disable MD013 -->
```json
{
  "skill_name": "csv-analyzer",
  "evals": [
    {
      "id": 1,
      "prompt": "I have a CSV of monthly sales in data/sales_2025.csv. Find the top 3 months by revenue and make a bar chart.",
      "expected_output": "Bar chart image with the top 3 months, labeled axes and values.",
      "files": ["evals/files/sales_2025.csv"]
    }
  ]
}
```
<!-- rumdl-enable MD013 -->

Start with 2-3 cases. Do not invest in a large set before seeing the first round of output. Vary phrasing, formality, and detail. Include one boundary case: malformed input, an unusual request, or an instruction the skill could read two ways.

Prompts need realistic texture. "Process this data" tests nothing; a path, a column name, and a reason do.

Skip assertions at first. Add them after seeing what good output looks like, which is usually not what you would have predicted.

## Running with a baseline

Run each case twice, once with the skill and once without it. The difference is the only evidence that the skill earns its context cost.

Improving an existing skill, snapshot the current version first and use the snapshot as baseline:

```bash
cp -r <skill-dir> <workspace>/skill-snapshot/
```

Every run starts from clean context, or leftover state from earlier runs leaks into the result and the comparison becomes meaningless. Fresh subagents give this naturally; otherwise use separate sessions.

Give each run four inputs: skill path or nothing for baseline, the prompt, input files, output directory.

Record token count and duration when the client reports them, since nothing persists them later.

## Workspace layout

```text
csv-analyzer/
├── SKILL.md
└── evals/evals.json
csv-analyzer-workspace/
└── iteration-1/
    ├── eval-top-months-chart/
    │   ├── with_skill/
    │   │   ├── outputs/
    │   │   ├── timing.json
    │   │   └── grading.json
    │   └── without_skill/
    │       ├── outputs/
    │       └── timing.json
    └── benchmark.json
```

Each pass gets its own `iteration-N/`. Only `evals/evals.json` is hand-authored; the rest is produced during evaluation.

## Assertions

Assertions are verifiable statements about the output. Add them to each test case once you know what success looks like.

```json
"assertions": [
  "The output includes a bar chart image file",
  "The chart shows exactly 3 months",
  "Both axes are labeled",
  "The chart title or caption mentions revenue"
]
```

Good assertions are checkable by code or careful reading: "the output file is valid JSON", "the report contains at least 3 recommendations".

Weak assertions fail either way: "the output is good" cannot be graded, and "uses the exact phrase 'Total Revenue: $X'" fails correct work that words it differently.

Not everything deserves an assertion. Style, visual design, and whether output feels right are hard to reduce to pass/fail. Leave those to human review.

## Grading

Grade each assertion PASS or FAIL with evidence quoted from the output, not asserted.

<!-- rumdl-disable MD013 -->
```json
{
  "assertion_results": [
    { "text": "Both axes are labeled", "passed": false, "evidence": "Y-axis reads 'Revenue ($)' but X-axis has no label" }
  ],
  "summary": { "passed": 3, "failed": 1, "total": 4, "pass_rate": 0.75 }
}
```
<!-- rumdl-enable MD013 -->

Mechanical checks belong in a verification script, which beats LLM judgment and is reusable across iterations. Keep LLM grading for judgment calls.

Rules that matter:

- No credit for a label without substance. A section titled "Summary" holding one vague sentence fails an assertion about a real summary.
- Review the assertions too. An assertion that always passes measures nothing; one that always fails is broken, too hard, or checking the wrong thing.

For comparing two versions, blind comparison works well: present both outputs without saying which is which and let the judge score organization, formatting, usability, and polish on its own rubric. Two versions can pass every assertion and still differ hugely in quality.

## Benchmarking

Aggregate per configuration into `benchmark.json`.

<!-- rumdl-disable MD013 -->
```json
{
  "run_summary": {
    "with_skill": { "pass_rate": { "mean": 0.83, "stddev": 0.06 }, "tokens": { "mean": 3800 } },
    "without_skill": { "pass_rate": { "mean": 0.33, "stddev": 0.10 }, "tokens": { "mean": 2100 } },
    "delta": { "pass_rate": 0.5, "tokens": 1700 }
  }
}
```
<!-- rumdl-enable MD013 -->

The delta says what the skill costs and what it buys. Thirteen seconds for 50 points of pass rate is a good trade. Doubled tokens for two points usually is not.

Standard deviation means nothing with a single run per case. Early on, read raw counts and the delta.

## Reading the patterns

Averages hide what matters:

- Assertions passing in both configurations measure nothing. Remove or replace them; they inflate the with-skill rate without reflecting skill value.
- Assertions failing in both are broken, too hard, or aimed at the wrong thing. Fix before the next iteration.
- Assertions passing only with the skill show where the skill earns its place. Work out which instruction or script caused it and keep that content prominent.
- High variance across runs of the same eval means ambiguity in the instructions or a flaky test. Add examples or sharper wording.
- Time or token outliers point at a bottleneck. Read that run's transcript.

## Iterating

Three signals feed the rewrite: failed assertions give specific gaps, human feedback gives direction, transcripts give causes.

Give all three plus the current `SKILL.md` to a model and ask for changes. Connecting them by hand is tedious.

Constraints on those changes:

- Generalize. The skill serves prompts beyond the test set; fix the class of failure, not the instance.
- Cut before adding. If traces show wasted validation or unneeded intermediates, remove those instructions. A plateau under growing rule counts is a sign of over-constraint: delete instructions and see whether results hold.
- Explain why. "Do X because Y causes Z" is followed more reliably than "ALWAYS do X".
- Bundle repeated work. If each run rewrote the same helper, put it in `scripts/`.

Loop: propose changes, review and apply, rerun everything into `iteration-N+1/`, grade, aggregate, review by hand, repeat.

## When to stop

Stop when results satisfy you, human feedback comes back empty, or consecutive iterations show no real movement. An empty feedback file is the signal, not the absence of complaints.