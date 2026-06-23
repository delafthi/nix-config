{ pkgs, ... }:
{
  home.shellAliases = {
    oc = "opencode";
  };
  programs.opencode = {
    enable = true;
    context = ''
      Terse like caveman. Technical substance exact. Only fluff die. Drop: articles, filler (just/really/basically), pleasantries, hedging. Fragments OK. Short synonyms. Code unchanged. Pattern: [thing] [action] [reason]. [next step]. ACTIVE EVERY RESPONSE. No revert after many turns. No filler drift. Code/commits/PRs: normal. Off: "stop caveman" / "normal mode".

      ## Version Control

      - Prefer `jj` over `git`. Use `jj` commands by default.
      - Key commands: `jj new` (new change), `jj describe` (set message), `jj squash` (amend into parent), `jj log` (history), `jj diff` (show changes).

      ## Glossary Defaults

      - `change` (standalone noun): Jujutsu change object (not generic code change, not git commit).
        - Verb usage like "change <thing>", "change this", "change something": treat as normal English verb, not glossary term.
        - Phrases like "current change", "that change", "change <id>": treat as Jujutsu change.
      - `change <id>`: Jujutsu change referenced by change id (for example `qpvuntsm`).
      - `rev`: Jujutsu revision selector (`@`, `@-`, `main`, `description(foo)`, and similar).
      - `bookmark`: Jujutsu bookmark, not git branch.
      - `working copy`: current mutable checkout at `@`.
      - If user explicitly overrides a term in same prompt, user wording wins.

      ## External Actions

      - External actions blocked by default.
      - Only perform external actions when user explicitly uses verbs `post`, `publish`, or `push` for that exact action.
      - If user asks to create issue/PR/comment/release without those verbs, prepare draft content in current conversation only; do not run external CLI/API commands (for example `gh issue create`).
      - Wait for explicit follow-up like `post this issue`, `publish this`, or `push ...` before executing external action.
    '';
    settings = {
      autoupdate = false;
      share = "disabled";
      permission = {
        bash = {
          "*" = "ask";
          "ls" = "allow";
          "ls *" = "allow";
          "pwd" = "allow";
          "which *" = "allow";
          "jj status*" = "allow";
          "jj log*" = "allow";
          "jj diff*" = "allow";
          "jj git push*" = "ask";
          "jj show*" = "allow";
          "jj root*" = "allow";
          "jj bookmark list*" = "allow";
          "jj git remote list*" = "allow";
          "gh pr diff*" = "allow";
          "gh pr list*" = "allow";
          "gh pr view*" = "allow";
          "git status*" = "allow";
          "git diff*" = "allow";
          "git push*" = "ask";
          "gh issue create*" = "ask";
          "gh pr create*" = "ask";
          "gh pr comment*" = "ask";
          "gh release create*" = "ask";
        };
        read = {
          "*" = "allow";
          "*.env" = "deny";
          "*.env.*" = "deny";
          "*.env.example" = "allow";
          "*.key" = "deny";
          "*.pem" = "deny";
          "*.p12" = "deny";
          "*.pfx" = "deny";
          "*.p8" = "deny";
          "*.kdbx" = "deny";
          "*.agekey" = "deny";
          ".netrc" = "deny";
          "id_*" = "deny";
          "~/.ssh/**" = "deny";
          "~/.gnupg/**" = "deny";
          "~/.config/sops/**" = "deny";
        };
        webfetch = "allow";
        websearch = "allow";
      };
    };
    tui = {
      keybinds = {
        session_new = "<leader>c";
        session_compact = "<leader>C";
        session_child_cycle = "<leader>n";
        session_child_cycle_reverse = "<leader>p";
      };
    };
    commands = {
      codedocs = ./commands/codedocs.md;
      commit = ./commands/commit.md;
      onboard = ./commands/onboard.md;
      pr = ./commands/pr.md;
      readme = ./commands/readme.md;
      review = ./commands/review.md;
      write-tests = ./commands/write-tests.md;
    };
    skills = {
      caveman = "${pkgs.caveman}/skills/caveman";
      context7-cli = "${pkgs.ctx7}/skills/context7-cli";
      jj = ./skills/jj;
    };
  };
}
