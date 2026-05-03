---
description: Write tests
agent: build
subtask: true
template: Create comprehensive, high-quality test cases for the provided files or current changes.
---

# Write tests

Create comprehensive, high-quality test cases for the files $ARGUMENTS or the current changes.

## Check

- Existing test framework, layout, and naming
- Related tests for target files
- Test config and helper fixtures

Use project test stack and conventions.

## Cover

- Happy path
- Edge cases/boundaries
- Error handling/invalid input
- Integration boundaries (mock external systems as needed)

## Rules

- Deterministic, isolated, readable tests
- One behavior per test
- Prefer behavior over implementation details
- Use specific assertions
- Add comments only for non-obvious setup/logic
- Skip trivial getters/setters, generated code, third-party internals

## Output

- Produce runnable test files in existing structure
- Include required imports/setup only
- Keep tests minimal and concise
