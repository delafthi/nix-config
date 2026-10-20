import { expect, test } from "bun:test";
import { findSuggestion } from "../src/index.ts";

const cases: [command: string, blocked: boolean][] = [
  ["git status", true],
  ["jj status", false],
  ["echo hi", false],
  ["echo git status", false],
  ["sudo git log", true],
  ["env FOO=1 git diff", true],
  ["timeout 5 git fetch", true],
  ["bash -c 'git push'", true],
  ['sh -c "echo $(git status)"', true],
  ["ls && git status", true],
  ["git commit --amend", true],
  ["git -c core.pager=cat log", true],
  ["JJ_BLACKBELT_FORFEIT=1 git status", false],
  ["cat <<EOF\n$(git status)\nEOF", true],
  ["git rev-parse HEAD", true],
  ["git some-unknown-thing", false],
  ["", false],
];

for (const [command, blocked] of cases) {
  test(`${blocked ? "blocks" : "allows"} ${JSON.stringify(command)}`, () => {
    expect(findSuggestion(command) !== undefined).toBe(blocked);
  });
}

test("suggests the closest jj command", () => {
  expect(findSuggestion("git commit --amend")).toBe(
    "Use `jj describe` instead.",
  );
  expect(findSuggestion("git branch -d main")).toBe(
    "Use `jj bookmark delete` instead.",
  );
  expect(findSuggestion("git checkout -b feature")).toBe(
    "Use `jj bookmark create` instead.",
  );
  expect(findSuggestion("git add .")).toContain("jj new");
});
