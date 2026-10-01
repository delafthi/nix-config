---
description: Pin down what the user actually wants before building - interview them in numbered rounds, push back on the answers, then close with a restatement they confirm. Use when a request admits several valid interpretations, when the goal is still fuzzy, when only the outcome is named and not the requirements, or when you want your assumptions interrogated before committing to them. Also when the user names a topic after the command.
agent: plan
subtask: false
---

# Interview Me

This command has no method of its own. The method lives in the `interview-me`
skill: when the request is ambiguous enough to interview, load that skill and
follow it as written. It owns the rounds, the confidence gate, the prototype
escape, and the restate.

`$ARGUMENTS` is the topic to scope, if one was given. Hand it to the skill as
the subject to state a hypothesis about, and let its confidence gate decide
between interviewing and going straight to the restate.
