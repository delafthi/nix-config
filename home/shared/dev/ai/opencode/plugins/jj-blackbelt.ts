import type { Plugin } from "@opencode-ai/plugin";

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

const FORFEIT_RE = /^JJ_BLACKBELT_FORFEIT=(["']?)(?:1|true|yes)\1$/i;

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

const BOOKMARK_CREATE_RE = /-[bc]\b|--branch\b/i;
const BOOKMARK_DELETE_RE = /-d\b|--delete\b/i;

type Token = { w: string; s: number; e: number };

function tokenize(s: string): Token[] {
  const tokens: Token[] = [];
  let buf = "";
  let start = 0;
  let quote: string | null = null;
  const flush = (end: number) => {
    if (buf !== "") tokens.push({ w: buf, s: start, e: end });
    buf = "";
  };
  for (let i = 0; i < s.length; i++) {
    const ch = s[i];
    if (quote === "'") {
      if (ch === "'") quote = null;
      buf += ch;
    } else if (quote === '"') {
      if (ch === "\\" && i + 1 < s.length) {
        buf += s[i + 1];
        i++;
      } else {
        if (ch === '"') quote = null;
        buf += ch;
      }
    } else if (ch === "'" || ch === '"') {
      if (buf === "") start = i;
      quote = ch;
      buf += ch;
    } else if (ch === "\\") {
      if (buf === "") start = i;
      buf += ch;
      if (i + 1 < s.length) {
        buf += s[i + 1];
        i++;
      }
    } else if (/\s/.test(ch)) {
      flush(i);
    } else if (ch === ";" || ch === "&" || ch === "|") {
      flush(i);
      if (ch === "&" && s[i + 1] === "&") i++;
      if (ch === "|" && s[i + 1] === "|") i++;
    } else {
      if (buf === "") start = i;
      buf += ch;
    }
  }
  flush(s.length);
  return tokens;
}

function unquote(w: string): string {
  if (
    w.length >= 2 &&
    ((w.startsWith('"') && w.endsWith('"')) ||
      (w.startsWith("'") && w.endsWith("'")))
  ) {
    return w.slice(1, -1);
  }
  return w;
}

function isShell(w: string): boolean {
  if (SHELLS.has(w)) return true;
  const base = w.split("/").pop();
  return base !== undefined && SHELLS.has(base);
}

function shellCommandString(tokens: Token[], i: number): string | undefined {
  let j = i + 1;
  while (j < tokens.length && tokens[j].w.startsWith("-")) {
    const flag = tokens[j].w;
    if (!flag.startsWith("--") && /c/.test(flag)) {
      return j + 1 < tokens.length ? unquote(tokens[j + 1].w) : undefined;
    }
    j++;
  }
  return undefined;
}

function gitSubcommand(
  command: string,
  tokens: Token[],
  i: number,
): { sub: string; slice: string } | undefined {
  let j = i + 1;
  while (j < tokens.length && tokens[j].w.startsWith("-")) {
    if (
      (tokens[j].w === "-c" || tokens[j].w === "-C") &&
      j + 1 < tokens.length
    ) {
      j += 2;
    } else {
      j++;
    }
  }
  if (j >= tokens.length) return undefined;
  const sub = tokens[j].w.toLowerCase();
  if (!/^[a-z][a-z0-9-]*$/.test(sub)) return undefined;
  return { sub, slice: command.slice(tokens[i].s) };
}

function findSuggestion(command: string): string | undefined {
  const tokens = tokenize(command);
  for (const t of tokens) {
    if (FORFEIT_RE.test(t.w)) return undefined;
  }
  for (let i = 0; i < tokens.length; i++) {
    const t = tokens[i];
    if (t.w.toLowerCase() === "git") {
      const hit = gitSubcommand(command, tokens, i);
      if (hit) {
        const message = suggest(hit.sub, hit.slice);
        if (message) return message;
      }
    }
    if (isShell(t.w)) {
      const inner = shellCommandString(tokens, i);
      if (inner) {
        const message = findSuggestion(inner);
        if (message) return message;
      }
    }
  }
  return undefined;
}

const suggest = (sub: string, cmd: string): string | undefined => {
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
};

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
