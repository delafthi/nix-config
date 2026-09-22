import type { Plugin } from "@opencode-ai/plugin";
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

function scanWord(word: U.Word | undefined): string | undefined {
  if (!word) return undefined;
  return scanParts(word.parts ?? []);
}

function scanWords(
  words: (U.Word | undefined)[] | undefined,
): string | undefined {
  for (const word of words ?? []) {
    const hit = scanWord(word);
    if (hit) return hit;
  }
  return undefined;
}

function scanArithmetic(
  expr: U.ArithmeticExpression | undefined,
): string | undefined {
  if (!expr) return undefined;
  switch (expr.type) {
    case "ArithmeticBinary":
      return scanArithmetic(expr.left) ?? scanArithmetic(expr.right);
    case "ArithmeticUnary":
      return scanArithmetic(expr.operand);
    case "ArithmeticTernary":
      return (
        scanArithmetic(expr.test) ??
        scanArithmetic(expr.consequent) ??
        scanArithmetic(expr.alternate)
      );
    case "ArithmeticGroup":
      return scanArithmetic(expr.expression);
    case "ArithmeticWord":
      return scanParts(expr.parts ?? []);
    case "ArithmeticCommandExpansion":
      return expr.script ? scanScript(expr.script) : undefined;
  }
  return undefined;
}

function scanParts(parts: U.WordPart[]): string | undefined {
  for (const part of parts) {
    let hit: string | undefined;
    switch (part.type) {
      case "CommandExpansion":
      case "ProcessSubstitution":
        hit = part.script ? scanScript(part.script) : undefined;
        break;
      case "DoubleQuoted":
      case "LocaleString":
        hit = scanParts(part.parts);
        break;
      case "BraceExpansion":
      case "ExtendedGlob":
        hit = scanParts(part.parts ?? []);
        break;
      case "ParameterExpansion":
        hit =
          scanParts(part.indexParts ?? []) ??
          scanWords([
            part.operand,
            part.slice?.offset,
            part.slice?.length,
            part.replace?.pattern,
            part.replace?.replacement,
          ]);
        break;
      case "ArithmeticExpansion":
        hit = scanArithmetic(part.expression);
        break;
    }
    if (hit) return hit;
  }
  return undefined;
}

function scanRedirects(redirects: U.Redirect[]): string | undefined {
  // Heredoc bodies are literal content — only targets can run code.
  return scanWords(redirects.map((r) => r.target));
}

function scanCommand(command: U.Command): string | undefined {
  for (const prefix of command.prefix) {
    const hit =
      scanParts(prefix.indexParts ?? []) ??
      scanWord(prefix.value) ??
      scanWords(prefix.array);
    if (hit) return hit;
  }
  const hit =
    scanWords([command.name, ...command.suffix]) ??
    scanRedirects(command.redirects);
  if (hit) return hit;
  if (!command.name) return undefined;
  return checkHead([command.name, ...command.suffix]);
}

function scanCompoundList(
  list: U.CompoundList | undefined,
): string | undefined {
  return scanStatements(list?.commands);
}

function scanStatements(
  statements: U.Statement[] | undefined,
): string | undefined {
  for (const statement of statements ?? []) {
    const hit = scanStatement(statement);
    if (hit) return hit;
  }
  return undefined;
}

function scanNode(node: U.Node | undefined): string | undefined {
  if (!node) return undefined;
  switch (node.type) {
    case "Command":
      return scanCommand(node);
    case "Pipeline":
    case "AndOr":
      for (const child of node.commands) {
        const hit = scanNode(child);
        if (hit) return hit;
      }
      return undefined;
    case "If":
      return (
        scanCompoundList(node.clause) ??
        scanCompoundList(node.then) ??
        (node.else?.type === "If"
          ? scanNode(node.else)
          : scanCompoundList(node.else))
      );
    case "For":
    case "Select":
      return scanWords(node.wordlist) ?? scanCompoundList(node.body);
    case "While":
      return scanCompoundList(node.clause) ?? scanCompoundList(node.body);
    case "Function":
    case "Coproc":
      return scanNode(node.body) ?? scanRedirects(node.redirects);
    case "Subshell":
    case "BraceGroup":
      return scanCompoundList(node.body);
    case "Case":
      for (const item of node.items) {
        const hit = scanWords(item.pattern) ?? scanCompoundList(item.body);
        if (hit) return hit;
      }
      return scanWord(node.word);
    case "ArithmeticFor":
      return scanCompoundList(node.body);
  }
  return undefined;
}

function scanStatement(statement: U.Statement): string | undefined {
  return scanNode(statement.command) ?? scanRedirects(statement.redirects);
}

function scanScript(script: U.ParsedScript): string | undefined {
  return scanStatements(script.commands);
}

function findSuggestion(command: string): string | undefined {
  if (FORFEIT_RE.test(command)) return undefined;
  return scanScript(parse(command));
}

export const JjBlackbelt: Plugin = async () => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return;
      const command = output.args?.command;
      if (typeof command !== "string" || command.trim() === "") return;
      const message = findSuggestion(command);
      if (message) throw new Error(message + FORFEIT_HINT);
    },
  };
};

export default JjBlackbelt;
