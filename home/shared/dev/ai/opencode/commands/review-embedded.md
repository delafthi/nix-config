---
description: Evidence-based review of C/C++ firmware for embedded anti-patterns - ISR context, RTOS, memory lifetime, MMIO, MISRA/CERT conformance. Read-only.
agent: plan
subtask: false
---

# Review embedded

Find embedded-specific defects in the C/C++ firmware under `$ARGUMENTS`. The
knowledge that earns its place here: what is legal in thread context and what
is not, memory lifetime on a constrained target, hardware coupling, and the
MISRA/CERT rule numbers you can actually cite.

Read the `code-review` skill for the lane
threshold, the evidence rule, the severity rubric, the merge rules, and the
output shape. It owns that machinery for `/review` too, which is why this
command cannot restate it: a command file cannot read a sibling command.
Everything below is the firmware delta.

## Before You Start

Read `CONTEXT.md`, `docs/`, and the component `README.md` or codedocs. Use the
project's established terms. Don't re-litigate ADRs.

Check what the project already enforces and do not report it as a gap:
compiler warning flags, static analysis in CI, a coding standard file, a MISRA
deviation log. Read the build files and the CI config first.

## Target selection

1. The first token of `$ARGUMENTS` is a bare number (`123`) or `#` + number
   (`#123`) — PR mode. Strip the `#`. Confirm with `gh pr view <number>` before
   anything else; if it fails, report the blocker and stop. Never guess a number
   into PR mode.
2. `$ARGUMENTS` is not empty — every token is a path. A directory expands to
   the files under it, recursive. A missing or unreadable path is a blocker:
   list it and keep reviewing the rest.
3. `$ARGUMENTS` is empty — current Jujutsu change (`@`). If `jj diff` reports
   nothing, say `working copy is empty` under `## Blockers` and stop.

## Lanes

Dispatch by the `code-review` skill's `## Parallelization`, with one subagent
per lane that has hits in the enumeration, six lanes maximum. A lane with no
hit is not dispatched; note it in Residual Risk.

Anchors below are `rg` patterns over the enumerated files. They find candidates,
never findings.

- **Lane A — Memory**: stack depth against the task stack, allocation on an ISR
  or RTOS path, pointer lifetime past its frame, freed-then-used, uninitialised
  locals. Anchors: `\b(malloc|calloc|realloc|free)\s*\(`,
  `return\s+&\w`.
- **Lane B — Concurrency, ISRs, determinism**: ISR context discipline, state
  shared across contexts, lock order across modules, unbounded waits,
  priority inversion, missing barrier, non-reentrant code on an interrupt path.
  Anchors: `\bportMAX_DELAY\b`, `(\w+_Handler|IRQHandler)\s*\(`,
  `\b(taskENTER_CRITICAL|__disable_irq|critical_section)\b`.
- **Lane C — Safety and failure paths**: bounds on a wire-supplied length,
  integer wrap, string termination, writes through `const` flash data,
  watchdog and fail-safe state, debug hooks left in shipped code.
  Anchors: `\b(strcpy|strcat|sprintf)\s*\(`,
  `for\s*\([^)]*\b(len|size|count)\b`.
- **Lane D — Hardware and architecture**: register access inside logic, MMIO
  without `volatile`, globals where a parameter belongs, one configuration
  value with three homes, stale state. Anchors:
  `\(u?int(8|16|32)_t\s*\*\s*\)\s*0x`,
  `^\s*#define\s+\w*(MAX|MIN|COUNT|SIZE)\w*\s`.
- **Lane E — Error handling and logging**: swallowed status, logs with no
  context, unbounded log buffer, secrets in logs, no escalation path from
  retry to reset. Anchors: `\b(printf|puts|log_\w+)\s*\(`.
- **Lane F — Types, portability, performance**: `int` width for stored or wire
  state, `sizeof` on a parameter that already decayed, endianness assumptions,
  `volatile` blocking an optimisation that mattered. Anchors:
  `\bint\s+\w+\s*(=|;|\[)`, `sizeof\s*\(\s*\w+\s*\)`.

Architecture findings that want a seam, not a lint fix, belong to
`/improve-architecture`. Do not restate its vocabulary here.

## Pattern examples

Illustrative, not exhaustive. These are the shapes that get missed in review,
not a catalogue. Search the lane anchors first, then read for these.

```c
// A: heap on a path that must not block, and no failure path
void TIM2_IRQHandler(void) {
    char *buf = malloc(256);      // ISR context: no heap, ever
    buf[0] = 'a';                 // and no NULL check
}

// A: pointer outlives the frame it points into
uint8_t *bad_get_buffer(void) {
    uint8_t tmp[64];
    return tmp;
}

// B: low-priority holder blocks, so the high-priority waiter never runs
void low_prio_task(void *pv) {
    xSemaphoreTake(mutex, portMAX_DELAY);
    vTaskDelay(pdMS_TO_TICKS(500));  // holds the lock while blocking
    xSemaphoreGive(mutex);
}

// B: read-modify-write on shared state, no atomic, two contexts
int32_t shared_counter;
void inc_counter(void) { shared_counter++; }  // torn on an 8/16-bit MCU

// C: length from the frame, buffer size from the compiler
void process_msg(uint8_t *msg, int len) {
    uint8_t buf[32];
    for (int i = 0; i < len; i++) buf[i] = msg[i];  // len > 32 overflows
}

// C: writing through a const table that lives in flash
const int32_t lut[] = {1, 2, 3};
*(int32_t*)lut = 42;                  // UB, may fault on the target

// D: register write inside business logic, no HAL, no volatile
static uint32_t *GPIOA_ODR = (uint32_t*)0x40020014;
void set_led(int on) {
    if (on) *GPIOA_ODR |= (1 << 5);   // MMIO needs volatile and a seam
}

// F: sizeof on a parameter that already decayed to a pointer
void clear(uint8_t buf[32]) {
    memset(buf, 0, sizeof(buf));      // sizeof(uint8_t*), not 32
}

// E: log grows until it overflows
static char log[10000];
void log_event(const char *msg) { strcat(log, msg); }

// D: one configuration value, three homes
// module_a.h: #define MAX_CONNECTIONS 5
// module_b.h: #define MAX_CONNECTIONS 5
// module_c.c: int max_conn = 5;
```

## Standards

Cite a rule number only when you can name the rule's text. Otherwise cite the
anti-pattern and say the number is unchecked — a wrong rule number is worse
than none. Verified against the MISRA C:2012 and MISRA C++:2023 tables
below:

| Anti-pattern | MISRA C:2012 | MISRA C++:2023 |
|--------------|--------------|----------------|
| Heap allocation anywhere | 21.3 | 21.6.1, 21.6.2 |
| Cast removing `const` or `volatile` | 11.8 | 8.2.3 |
| Recursion, direct or indirect | 17.2 | 8.2.10 |
| Returning a pointer to an automatic local | — | 6.8.2 (mandatory) |
| Pointer arithmetic leaving the array | 18.1 | 8.7.1 |
| `union` used for reinterpretation | 19.2 | 12.3.1 |
| Macro parameter used unparenthesised | 20.7 | 19.3.4 |
| `switch` structure, `default` label | 16.3, 16.4 | 9.4.1, 9.4.2 |
| Array parameter decay | 12.5 | 7.11.2 |
| Plain `int` for stored or wire state | — | 6.9.2 |
| Global mutable state | — | 6.7.2 |
| Local `static` used as scratch | — | 6.7.1 |
| Floating-point arithmetic | — | Dir 0.3.1 (a directive, not a rule) |

CERT C covers the memory-safety rules in Lane C. AUTOSAR C++14 covers the
automotive subset. Attach an identifier from either only when you can name it.

## Severity

The five bands of the `code-review` skill, recalibrated to firmware:

- 🔴 `CRITICAL`: reachable safety violation, memory corruption, or a hang on
  the target
- 🟠 `HIGH`: corruption of memory or shared state with a plausible trigger
- 🟡 `MEDIUM`: correctness risk bounded to one code path
- 🟢 `LOW`: narrow edge case, or a portability defect on untested targets
- 💡 `SUGGESTION`: no defect; an improvement worth making

## Evidence rule

The `code-review` skill owns the two gates and the drop list. Firmware
calibration:

- A line inferred from an ISR vector table is not read, exactly as a diff hunk
  header is not read.
- Unreadable code here is vendor HAL, CMSIS, generated startup files, linker
  scripts, and third-party middleware. That exclusion is the largest single
  source of false findings in firmware review, and it is where hallucinations
  come from.
- Do not file a hardware or board claim with no code behind it — watchdog not
  armed, secure boot absent, brown-out not configured. Those are a design
  review, not this command.
- Do not file an anti-pattern with no `file:line` inside the enumerated scope.
- Do not file a tool or compiler diagnostic you have not opened.

## Per issue

Every field the `code-review` skill defines, plus the firmware fields:

- Category: the lane letter and name
- Impact on the target
- Reference: MISRA or CERT rule, or the anti-pattern name with the number left
  unchecked

## Output format

No cap. Every finding that survives both gates is reported in full. The read
gate and the drop list are what keep padding out, so nothing real is demoted or
trimmed to fit a count.

Deltas on the report the `code-review` skill defines:

- `## Summary` adds `Lanes dispatched: <letters>`.
- Zero issues: `No embedded design issues found`.
- Keep it objective and concise.
