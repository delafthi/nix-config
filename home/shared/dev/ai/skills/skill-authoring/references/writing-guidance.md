# Writing Guidance

How to shape skill content: what to include, how prescriptive to be, and which
instruction patterns pay off. Read this when writing a new skill or
restructuring an existing one.

- [Add what the agent lacks](#add-what-the-agent-lacks)
- [Scope as a coherent unit](#scope-as-a-coherent-unit)
- [Calibrate control to fragility](#calibrate-control-to-fragility)
- [Provide defaults, not menus](#provide-defaults-not-menus)
- [Favor procedures over declarations](#favor-procedures-over-declarations)
- [Instruction patterns](#instruction-patterns)
- [Gotchas](#gotchas)
- [Output templates](#output-templates)
- [Checklists for multi-step work](#checklists-for-multi-step-work)
- [Validation loops](#validation-loops)
- [Plan-validate-execute](#plan-validate-execute)
- [When to bundle a script](#when-to-bundle-a-script)
- [Refine with real execution](#refine-with-real-execution)
- [Splitting a skill that outgrew itself](#splitting-a-skill-that-outgrew-itself)

## Add what the agent lacks

Ask of every paragraph: would the agent get this wrong without this instruction?
If not, cut it.

```md
<!-- Wasteful: the model already knows this -->
PDF files are a common format containing text and images. To extract text,
use a library. pdfplumber is recommended because it handles most cases.

<!-- Valuable: only the specifics are unknown -->
Use pdfplumber for text extraction. For scanned documents, fall back to
pdf2image with pytesseract.
```

Explanation of a domain the model already knows in, schemas it can already read,
and generic best-practice advice all cost context and return nothing. If the
agent already handles the task well without the skill, the skill adds no value
and should not exist.

## Scope as a coherent unit

Decide scope the way you would scope a function: one coherent unit of work that
composes with other skills. Narrow scope forces several skills to load for one
task, which costs overhead and risks conflicting instructions. Wide scope
activates imprecisely.

Querying a database and formatting the result is one unit. Querying a database
plus administering it is two. A skill that has crossed 500 lines almost always
holds two or three.

## Calibrate control to fragility

Not every section needs the same level of prescriptiveness.

Give freedom where several approaches work and variation is acceptable.
Explaining why often beats a rigid directive, because an agent that understands
the purpose makes better context-dependent decisions.

```md
## Code review focus

1. Check database queries for injection; use parameterized queries
2. Verify an authentication check on every endpoint
3. Look for race conditions in concurrent paths
4. Confirm error messages leak no internal detail
```

Be prescriptive where operations are fragile, consistency matters, or an exact
sequence is required.

```md
## Database migration

Run exactly this sequence:

    python scripts/migrate.py --verify --backup

Do not add flags or reorder steps.
```

Most skills mix both. Calibrate section by section rather than picking one
register for the whole file.

Watch the environment when prescribing. A correct-by-default instruction that is
wrong on the user's actual machine, such as a global package install inside a
Nix-managed shell, will break every run. Verify the command works here before
writing it as the default.

## Provide defaults, not menus

Pick one approach and name the alternatives briefly.

```md
<!-- Menu: agent must choose, and usually guesses wrong -->
You can use pypdf, pdfplumber, PyMuPDF, or pdf2image...

<!-- Default plus escape hatch -->
Use pdfplumber for text extraction.

    import pdfplumber
    with pdfplumber.open("file.pdf") as pdf:
        text = pdf.pages[0].extract_text()

For scanned PDFs needing OCR, use pdf2image with pytesseract instead.
```

## Favor procedures over declarations

Teach how to approach a class of problems, not what to produce for one instance.

```md
<!-- Answers one task, useless for the next -->
Join orders to customers on customer_id, filter region = 'EMEA', sum amount.

<!-- Method that generalizes -->
1. Read the schema from references/schema.yaml to find relevant tables
2. Join tables using the _id foreign key convention
3. Apply the user's filters as WHERE clauses
4. Aggregate numeric columns and format as a markdown table
```

Specific details are still fine: output templates, constraints like "never emit
PII", and tool-specific instructions. It is the approach that must generalize.

## Instruction patterns

Reusable structures. Most skills need only a few.

## Gotchas

The highest-value content in many skills: environment-specific facts that defy
reasonable assumption. Not "handle errors appropriately", but the concrete
corrections the agent would otherwise get wrong.

```md
## Gotchas

- The users table uses soft deletes. Queries must add WHERE deleted_at IS NULL
  or deactivated accounts appear in results.
- The same value is user_id in the database, uid in the auth service, and
  accountId in the billing API.
- /health returns 200 whenever the web server runs, even with the database
  down. Use /ready for full health.
```

Every correction you have to give the agent belongs here. It is the most direct
improvement available.

## Output templates

When output must have a fixed shape, show the shape. Agents pattern-match
concrete structures far more reliably than prose descriptions.

```md
## Report structure

Adapt sections to the analysis:

    # [Title]

    ## Executive summary
    [One paragraph of key findings]

    ## Key findings
    - Finding 1 with supporting data
    - Finding 2 with supporting data

    ## Recommendations
    1. Specific, actionable
```

Short templates stay inline. Longer or rarely needed templates go in `assets/`
and get referenced so they load on demand.

## Checklists for multi-step work

An explicit list helps the agent track progress and not skip steps with
dependencies or validation gates.

```md
## Form processing workflow

- [ ] Analyze the form: run scripts/analyze_form.py
- [ ] Create field mapping: edit fields.json
- [ ] Validate mapping: run scripts/validate_fields.py
- [ ] Fill the form: run scripts/fill_form.py
- [ ] Verify output: run scripts/verify_output.py
```

## Validation loops

Instruct the agent to check its own work: do the work, run a validator, fix
issues, repeat until it passes.

```md
## Editing workflow

1. Make the edits
2. Validate: python scripts/validate.py output/
3. If validation fails: read the error, fix the cause, validate again
4. Proceed only when validation passes
```

A reference document can serve as the validator: check the output against the
reference before finalizing.

## Plan-validate-execute

For batch or destructive work, produce an intermediate plan, validate it against
a source of truth, then execute.

```md
1. Extract form fields: python scripts/analyze_form.py input.pdf -> form_fields.json
2. Create field_values.json mapping each field to its intended value
3. Validate: python scripts/validate_fields.py form_fields.json field_values.json
4. On failure, revise field_values.json and re-validate
5. Fill the form: python scripts/fill_form.py input.pdf field_values.json output.pdf
```

Step 3 is what makes this work. Errors like
`Field 'signature_date' not found - available: customer_name, order_total, signature_date_signed`
give the agent enough to self-correct.

## When to bundle a script

Compare traces across runs. When the agent independently rewrites the same logic
every time, build charts, parse a format, or validate output, that logic belongs
in `scripts/`.

Scripts should be self-contained or document their dependencies, fail with
actionable messages, and handle edge cases. They execute without loading into
context, so a script is cheaper than the instructions that would replace it.
Keep the invocation in the body and the implementation in the script.

## Refine with real execution

A first draft needs revision against real work. Feed all results back, not only
failures: what false-triggered, what was missed, what could be cut.

Read traces, not just final output. Common causes of wasted effort are
instructions too vague to act on, instructions that do not apply to the current
task but get followed anyway, and too many options with no default.

One pass of execute-then-revise helps noticeably. Complex domains need several.

## Splitting a skill that outgrew itself

Signals, in order of strength:

1. Two clusters of content that never appear in the same task.
2. Description needing "and also" to cover the scope.
3. Body past 500 lines.
4. Instructions that contradict once a task touches both halves.

Split by activation boundary, not by file size. Each new skill needs its own
description precise enough not to steal the other's prompts.
