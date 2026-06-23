---
description: Review embedded project for embedded system anti-patterns
agent: plan
subtask: false
---

# Review embedded project

Find bad designs in C/C++ embedded projects within `$ARGUMENTS`. Reference embedded design knowledge from theEmbeddedNewTestament and MISRA C++ guidelines.

## Target selection

1. If `$ARGUMENTS` empty, use current directory.
2. Else treat tokens as paths; scan each recursively.
3. Skip non-C/C++ source files unless they contribute to architecture understanding.
4. If path missing/unreadable, report as blocker and continue with valid paths.
5. Never mutate code during review.

## Anti-pattern sources

Use following knowledge bases as ground truth for what constitutes bad design:

- theEmbeddedNewTestament (github.com/theEmbeddedGeorge/theEmbeddedNewTestament.github.io) - embedded C programming, memory, RTOS, performance, security
- MISRA C/C++ guidelines for safety-critical code
- CERT C secure coding standards
- AUTOSAR C++14 guidelines for automotive

## Parallelization lanes

Use up to 9 subagents with independent lanes:

- **Lane A — Memory**: dynamic allocation in ISR/RT paths, leaks, fragmentation, stack overflow, no pool allocator, missing NULL checks after alloc, use-after-free, double-free, large stack frames, no
  volatile on MMIO, uninitialized locals
- **Lane B — Real-Time & Determinism**: priority inversion (no inheritance), deadlock (inconsistent lock order), infinite waits (portMAX_DELAY), long critical sections, nested locks, no timeout on
  acquisition, ISR doing blocking calls (printf/malloc), non-deterministic timing paths
- **Lane C — Performance**: cache-unfriendly access patterns (column-major), premature optimization, clever code defeating compiler opts, missing -Os/-O2 flag selection, no profiling before
  optimization, function-like macros instead of inline, unnecessary FPU use
- **Lane D — Safety & Security**: buffer overflow, no bounds checking, integer overflow/underflow, no watchdog, no stack canary, no fail-safe state, failing to NULL-terminate strings, type-punning via
  unions, casting away const, no secure boot, weak crypto, key exposure, no rollback protection, debug mode in prod
- **Lane E — Design Patterns & Architecture**: global state instead of explicit params, no HAL (hardware coupled to logic), god objects / monolithic modules, deep nested if-else (high cyclomatic
  complexity), mixing IO/computation/policy, no module boundaries, tight coupling, fall-through switch without comment, unbounded recursion, no early-return guards
- **Lane F — Error Handling & Logging**: swallowing errors silently, no context in logs (file/line/func), no severity levels, infinite log growth (no circular buffer), no recovery mechanism, no error
  escalation (retry->restart->reset), logging secrets, no fail-fast
- **Lane G — Concurrency**: shared global without mutex/lock, race conditions, missing memory barriers, no volatile on shared flags, non-reentrant functions in ISR, no atomic ops where appropriate,
  inconsistent lock ordering across modules
- **Lane H — Static Analysis & Standards**: no SA in CI, ignoring warnings, no MISRA deviation process, no custom rules for embedded, no coding standard enforced, no type safety (int instead of
  stdint.h), assumes sizeof(array param) works, assumes platform endianness
- **Lane I — Data/State Architecture**: duplicate data across modules (no single source of truth), copy-paste code duplication, inconsistent state machine patterns, no configuration management, magic
  numbers, redundant data storage, stale/dead code

## Pattern examples

Illustrative anchors — not exhaustive. Search for all patterns listed in lane descriptions above, plus structurally similar variants.

### Memory (Lane A)

```c
// BAD: returning stack address
uint8_t* bad_get_buffer(void) {
    uint8_t tmp[64];
    return tmp;  // UB — dangling pointer
}

// BAD: dynamic alloc in ISR
void TIM2_IRQHandler(void) {
    char *buf = malloc(256);  // non-deterministic, may sleep
    // MISRA C:2012 Rule 21.3 — no malloc in embedded
}

// BAD: unchecked malloc
char *p = malloc(100);
*p = 'a';  // NULL deref if alloc fails
```

### Real-Time & Determinism (Lane B)

```c
// BAD: priority inversion (low-prio holds lock, blocks high-prio)
void low_prio_task(void *pv) {
    xSemaphoreTake(mutex, portMAX_DELAY);
    vTaskDelay(pdMS_TO_TICKS(500));  // holding lock while blocking!
    xSemaphoreGive(mutex);
}

// BAD: inconsistent lock order (deadlock)
void task1(void *pv) { xSemaphoreTake(A, ...); xSemaphoreTake(B, ...); }
void task2(void *pv) { xSemaphoreTake(B, ...); xSemaphoreTake(A, ...); }  // deadlock
```

### Performance (Lane C)

```c
// BAD: column-major access (cache-unfriendly)
int sum_col_bad(int m[][100], int rows) {
    int s = 0;
    for (int j = 0; j < 100; j++)
        for (int i = 0; i < rows; i++)
            s += m[i][j];  // strides across rows — cache misses
    return s;
}
// GOOD: row-major — sequential access
int sum_row_good(int m[][100], int rows) {
    int s = 0;
    for (int i = 0; i < rows; i++)
        for (int j = 0; j < 100; j++)
            s += m[i][j];  // contiguous — cache hits
    return s;
}

// BAD: function-like macro instead of inline
#define SQUARE(x) ((x) * (x))  // no type safety, multiple eval
```

### Safety & Security (Lane D)

```c
// BAD: buffer overflow (no bounds check)
void process_msg(uint8_t *msg, int len) {
    uint8_t buf[32];
    for (int i = 0; i < len; i++) buf[i] = msg[i];  // len > 32 = overflow
}

// BAD: casting away const (data may be in flash)
const int32_t lut[] = {1, 2, 3};
*(int32_t*)lut = 42;  // UB — may write to ROM
// MISRA C:2012 Rule 11.8 — no cast that removes const
```

### Design Patterns (Lane E)

```c
// BAD: global state + no HAL — hardware coupled to logic
static uint32_t *GPIOA_ODR = (uint32_t*)0x40020014;
void set_led(int on) {
    if (on) *GPIOA_ODR |= (1 << 5);  // direct register access in business logic
    else    *GPIOA_ODR &= ~(1 << 5);
}

// BAD: deep nesting (high cyclomatic complexity)
void handle_cmd(int cmd, int arg) {
    if (cmd == 1) {
        if (arg > 0) {
            for (int i = 0; i < arg; i++) {
                if (i % 2 == 0) { /* ... */ }
            }
        }
    }  // 4 levels deep before real work
}
```

### Error Handling (Lane F)

```c
// BAD: swallowing error silently
int configure_timer(void) {
    if (hw_register_set(TIM_CR1, 0x01) != OK) {
        return -1;  // no log, no recovery, caller gets -1 with no context
    }
}

// BAD: unbounded log growth
void log_event(const char *msg) {
    static char log[10000];
    strcat(log, msg);  // grows forever until buffer overflows
}
```

### Concurrency (Lane G)

```c
// BAD: shared global without synchronization
int32_t shared_counter;
void inc_counter(void) { shared_counter++; }  // non-atomic on 8/16-bit MCU
// Both ISR and main loop access — race condition

// BAD: non-reentrant function used in ISR
int format_and_send(const char *fmt, ...) {
    static char buf[128];  // shared buffer, not reentrant
    vsnprintf(buf, sizeof(buf), fmt, args);
    return uart_send(buf);
}
void USART_IRQHandler(void) { format_and_send("rx: %x\n", data); }  // corruption
```

### Static Analysis & Standards (Lane H)

```c
// BAD: platform-dependent types
int counter;  // 16-bit on some, 32-bit on others — overflow risk
// GOOD: uint32_t counter;  — fixed width, portable
// MISRA C:2012 Rule 7.2 — use u?int*_t from <stdint.h>

// BAD: assumes sizeof(array param) works
void clear(uint8_t buf[32]) {
    memset(buf, 0, sizeof(buf));  // sizeof(buf) == sizeof(uint8_t*), not 32
}
```

### Data/State Architecture (Lane I)

```c
// BAD: duplicate canonical data
// module_a.h:   #define MAX_CONNECTIONS 5
// module_b.h:   #define MAX_CONNECTIONS 5
// module_c.c:   int max_conn = 5;
// — three copies of same configuration value
// FIX: single header of record, one source of truth

// BAD: magic numbers
void uart_set_baud(int rate) {
    UART_BRR = 16000000 / 9600;  // 9600 and 16MHz are magic
}
// FIX: #define F_CPU 16000000UL / named constants
```

## MISRA references

Link findings to specific MISRA rules when applicable. Key rules by domain:

| Area | MISRA C:2012 | MISRA C++:2023 |
|------|-------------|----------------|
| Dynamic allocation | Rule 21.3 — no calloc/malloc/realloc/free | Rule 18-4-1 — no dynamic heap |
| Pointer safety | Rule 11.8 — no cast removing const/volatile | Rule 5-2-5 — no cast removing const |
| Integer types | Rule 7.2 — use u?int*_t | Rule 3-9-2 — fixed-width types |
| Array bounds | Rule 18.1 — pointer + offset within bounds | Rule 5-0-16 — array index within range |
| Stack overflow | Rule 21.2 — no recursion (bounded) | Rule 7-5-4 — no recursion |
| Unions | Rule 19.2 — no union type-punning | Rule 9-5-1 — no union member read of inactive member |
| Switch fallthrough | Rule 16.3 — every switch has default | Rule 6-4-6 — switch must have default |
| Side effects in macro | Rule 20.7 — macro params parenthesized | Rule 16-0-6 — function macros safe |
| Boolean type | Rule 21.10 — bool used for boolean test | Rule 5-3-1 — operand of logical op is bool type |
| NULL check | Rule 21.17 — pointer may be NULL | — |
| Floating point | — | Rule 13-3-1 — FP used only where arithmetic permits |

## Merging

Primary agent merges all lane findings into one report:

- Deduplicate equivalent findings from multiple lanes.
- If two findings share root cause, keep one issue and mention all affected locations.
- Resolve conflicts by stronger evidence and higher severity.
- Preserve priority ordering from highest risk to lowest.

## Priority

1. Safety
2. Security
3. Memory
4. Determinism
5. Concurrency
6. Performance
7. Design Patterns
8. Error Handling
9. Architecture
10. Static Analysis

## Severity rubric

- `CRITICAL`: active exploit, data loss/corruption, safety violation, or crash likely
- `HIGH`: serious reliability/security impact with plausible trigger path
- `MEDIUM`: correctness/maintainability risk with limited blast radius
- `LOW`: minor risk or narrow edge case
- `SUGGESTION`: improvement with no clear defect

## Evidence rule

For each issue include:

- concrete location (`file:line`)
- why current code fails (condition/path)
- expected design vs actual design
- concise fix direction
- minimal verification step

Reject speculative findings without evidence from code.

## Per issue

- Severity: `CRITICAL | HIGH | MEDIUM | LOW | SUGGESTION`
- Confidence: `HIGH | MEDIUM | LOW`
- Category: `memory | realtime | performance | safety | security | design | error-handling | concurrency | static-analysis | architecture`
- Location: `file:line`
- Problem
- Impact
- Fix direction
- Reference (which anti-pattern from theEmbeddedNewTestament/MISRA/CERT)
- Verification (test idea or command)

## Output format

- List highest-risk issues first.
- Deduplicate equivalent issues.
- Default cap: 20 detailed issues; summarize remainder briefly.
- If zero actionable issues, state: `No embedded design issues found`.
- Keep feedback actionable, objective, concise.

Use this output shape:

```text
## Summary
- Total issues: X
- Critical: X
- High: X
- Medium: X
- Low: X
- Suggestion: X
- Categories hit: memory, realtime, ...

## Blockers
- <missing path / failure details>

## Issues
- [SEVERITY] [Confidence] [Category] `path/to/file:line` - problem, impact, fix, reference, verification

## Residual Risk
- <what was not fully validated>
```
