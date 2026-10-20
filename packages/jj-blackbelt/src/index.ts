import { Plugin } from "@opencode/plugin";
import type * as U from "unbash";
import { parse } from "unbash";

const TRACK_MSG =
  "Use `jj new` instead. Files are always tracked, no staging — `jj split` separates changes. See the jj skill for the workflow.";

const SUGGESTIONS: Record<string, string> = {
  status: "Use `jj status` instead.",
  diff: "Use `jj diff` instead.",
  log: "Use `jj log` instead.",
  show: "Use `jj show` instead.",
  add: TRACK_MSG,
  rm: TRACK_MSG,
  mv: TRACK_MSG,
  commit: 'Use `jj describe -m "..."` instead.',
  branch: "Use `jj bookmark` instead.",
  checkout: "Use `jj new` instead.",
  switch: "Use `jj new` instead.",
  merge: "Use `jj rebase` or `jj squash` instead.",
  rebase: "Use `jj rebase` instead.",
  pull: "Use `jj git fetch` instead.",
  push: "Use `jj git push --bookmark <name>` instead.",
  fetch: "Use `jj git fetch` instead.",
  remote: "Use `jj git remote` instead.",
  reset: "Use `jj restore` (or `jj undo`) instead.",
  restore: "Use `jj restore` instead.",
  stash:
    "No stash in jj. The working copy is a mutable snapshot — park work with `jj new`. See the jj skill for the workflow.",
  revert: "Use `jj undo` instead.",
  blame: "Use `jj file annotate` instead.",
  "rev-parse": "Use `jj log` / `jj root` instead.",
  clone: "Use `jj git clone` instead.",
  init: "Use `jj init` instead.",
};

const FORFEIT_HINT =
  "\nIf you truly need git: JJ_BLACKBELT_FORFEIT=1 <command>";

const FORFEIT_RE =
  /(?:^|\s)JJ_BLACKBELT_FORFEIT=(["']?)(?:1|true|yes)\1(?:\s|$)/i;

const SHELLS = new Set([
  "bash",
  "sh",
  "zsh",
  "fish",
  "ksh",
  "dash",
  "ash",
  "csh",
  "tcsh",
  "pwsh",
  "nu",
]);

const WRAPPERS = new Set([
  "sudo",
  "env",
  "command",
  "builtin",
  "time",
  "timeout",
  "nohup",
  "nice",
  "stdbuf",
  "watch",
  "doas",
]);

// Wrappers taking a positional value before the wrapped command.
const WRAPPER_POSITIONALS: Record<string, number> = { timeout: 1 };

const BOOKMARK_CREATE_RE = /-[bc]\b|--branch\b/i;
const BOOKMARK_DELETE_RE = /-d\b|--delete\b/i;
const ASSIGN_RE = /^[A-Za-z_][A-Za-z0-9_]*=/;

const basename = (word: string): string =>
  (word.split("/").pop() ?? word).toLowerCase();

const isCommandLike = (word: string): boolean => {
  const base = basename(word);
  return base === "git" || SHELLS.has(base) || WRAPPERS.has(base);
};

function suggest(sub: string, cmd: string): string | undefined {
  switch (sub) {
    case "commit":
      return /--amend\b/.test(cmd)
        ? "Use `jj describe` instead."
        : SUGGESTIONS.commit;
    case "branch":
      return BOOKMARK_DELETE_RE.test(cmd)
        ? "Use `jj bookmark delete` instead."
        : SUGGESTIONS.branch;
    case "checkout":
    case "switch":
      return BOOKMARK_CREATE_RE.test(cmd)
        ? "Use `jj bookmark create` instead."
        : SUGGESTIONS.checkout;
    default:
      return SUGGESTIONS[sub];
  }
}

function gitSuggestion(words: U.Word[], i: number): string | undefined {
  let j = i + 1;
  while (j < words.length && words[j].value.startsWith("-")) {
    if (
      (words[j].value === "-c" || words[j].value === "-C") &&
      j + 1 < words.length
    ) {
      j += 2;
    } else {
      j++;
    }
  }
  if (j >= words.length) return undefined;
  const sub = words[j].value.toLowerCase();
  if (!/^[a-z][a-z0-9-]*$/.test(sub)) return undefined;
  const cmd = words
    .slice(i)
    .map((w) => w.text)
    .join(" ");
  return suggest(sub, cmd);
}

function shellInlineScript(words: U.Word[], i: number): string | undefined {
  for (let j = i + 1; j < words.length; j++) {
    const flag = words[j].value;
    if (!flag.startsWith("-")) return undefined;
    if (!flag.startsWith("--") && /c/.test(flag)) {
      return j + 1 < words.length ? words[j + 1].value : undefined;
    }
  }
  return undefined;
}

// Resolve a command's head word through env assignments, wrappers, and
// nested shells to a git invocation; return its suggestion if any.
function checkHead(words: U.Word[]): string | undefined {
  let i = 0;
  let positionals = 0;
  while (i < words.length) {
    const word = words[i].value;
    if (ASSIGN_RE.test(word)) {
      i++;
      continue;
    }
    const base = basename(word);
    if (base === "git") return gitSuggestion(words, i);
    if (SHELLS.has(base)) {
      const inner = shellInlineScript(words, i);
      return inner === undefined ? undefined : findSuggestion(inner);
    }
    if (WRAPPERS.has(base)) {
      positionals = WRAPPER_POSITIONALS[base] ?? 0;
      i++;
      continue;
    }
    if (word.startsWith("-")) {
      // Wrapper flags: single-char flags may consume the next word as value.
      if (
        /^-[a-zA-Z]$/.test(word) &&
        !isCommandLike(words[i + 1]?.value ?? "")
      ) {
        i += 2;
      } else {
        i++;
      }
      continue;
    }
    if (positionals > 0) {
      positionals--;
      i++;
      continue;
    }
    return undefined;
  }
  return undefined;
}

// Walk every node rather than each node type. unbash exposes `parts` as a lazy
// prototype accessor, so it is not reachable through Object.values.
function* commands(node: unknown): Generator<U.Command> {
  if (Array.isArray(node)) {
    for (const child of node) yield* commands(child);
    return;
  }
  if (!node || typeof node !== "object") return;
  if ((node as { type?: string }).type === "Command") {
    yield node as U.Command;
  }
  for (const child of Object.values(node)) yield* commands(child);
  if ("parts" in node) yield* commands((node as U.Word).parts);
}

export function findSuggestion(command: string): string | undefined {
  if (FORFEIT_RE.test(command)) return undefined;
  for (const node of commands(parse(command))) {
    if (!node.name) continue;
    const hit = checkHead([node.name, ...node.suffix]);
    if (hit) return hit;
  }
  return undefined;
}

export default Plugin.define({
  id: "jj-blackbelt",
  async setup(ctx) {
    await ctx.tool.hook("execute.before", (event) => {
      if (event.tool !== "bash") return;
      const command = (event.input as { command?: unknown }).command;
      if (typeof command !== "string" || command.trim() === "") return;
      const message = findSuggestion(command);
      if (message) throw new Error(message + FORFEIT_HINT);
    });
  },
});
