{ config, pkgs, ... }:
{
  home.shellAliases = {
    oc = "opencode";
  };
  programs.opencode = {
    enable = true;
    context = ''
      ## Output Format

      Respond terse like smart caveman. All technical substance stay. Only fluff die.

      Rules:
      - Drop: articles (a/an/the), filler (just/really/basically), pleasantries, hedging
      - Fragments OK. Short synonyms. Technical terms exact. Code unchanged.
      - Pattern: [thing] [action] [reason]. [next step].
      - Not: "Sure! I'd be happy to help you with that."
      - Yes: "Bug in auth middleware. Fix:"

      Stop: "stop caveman" or "normal mode"

      Auto-Clarity: drop caveman for security warnings, irreversible actions, user confused. Resume after.

      Boundaries: code/commits/PRs written normal.

      ## Glossary

      - `change`: Jujutsu change object (verb usage = normal English).
      - `rev`: Jujutsu revision selector (`@`, `@-`, `main`, `description(foo)`).
      - `bookmark`: Jujutsu bookmark, not git branch.
      - `working copy`: current mutable checkout at `@`.
      - User wording wins when explicitly overridden.

      ## Preferred tools

      - `fd` over `find`, `rg` over `grep`, `bat` over `cat`, `delta` over `diff`, `eza` over `ls`
      - `jq` for JSON, `tokei` for metrics, `hyperfine` for benchmarks, `ouch` for archives

      ## Version Control

      - Prefer `jj` over `git`. Key commands: `jj new`, `jj describe`, `jj squash`, `jj log`, `jj diff`.

      ## Scratch

      - `/tmp/opencode` for scratch work outside workspace.

      ## Search

      - Clone reference projects to `${config.home.homeDirectory}/Projects/ref` — prefer local source over web search.

      ## Nix

      - Nix manages dev environment. Projects not necessarily Nix projects.
      - Check `flake.nix` before assuming tool is unavailable.
      - `nix-locate` installed — find packages for missing binaries/libraries.
      - `nix run nixpkgs#<tool>` for one-off access.

      ## Workflow

      - Read existing patterns before writing code.
      - Confirm understanding before implementing. Restate what you think, wait for yes.
      - Use `todowrite` to track multi-step tasks. Update as you go.
      - Don't duplicate — check if something exists before creating it.
      - Complex work: delegate to subagents, track progress, summarize results.
      - Stuck after a few attempts? Ask rather than guess — saves time for both.

      ## Conventions

      - Check `CONTRIBUTING.md`, lint configs, style guides before editing.
      - Mirror existing code style. Don't re-litigate conventions.

      ## External Actions

      - Blocked by default. Only `post`, `publish`, `push` when explicitly requested.
      - If asked to create issue/PR/comment/release without those verbs, prepare draft only.
    '';
    settings = {
      autoupdate = false;
      share = "disabled";
      permission = {
        bash = {
          "*" = "ask";
          "basename *" = "allow";
          "bat *" = "allow";
          "cut *" = "allow";
          "date" = "allow";
          "delta *" = "allow";
          "dirname *" = "allow";
          "echo *" = "allow";
          "eza" = "allow";
          "eza *" = "allow";
          "fd" = "allow";
          "fd *" = "allow";
          "fold *" = "allow";
          "gh pr diff *" = "allow";
          "gh pr list" = "allow";
          "gh pr list *" = "allow";
          "gh pr view *" = "allow";
          "git diff" = "allow";
          "git diff *" = "allow";
          "git status" = "allow";
          "git status *" = "allow";
          "head *" = "allow";
          "hyperfine *" = "allow";
          "jj bookmark list" = "allow";
          "jj bookmark list *" = "allow";
          "jj diff" = "allow";
          "jj diff *" = "allow";
          "jj git remote list" = "allow";
          "jj git remote list *" = "allow";
          "jj log" = "allow";
          "jj log *" = "allow";
          "jj root" = "allow";
          "jj root *" = "allow";
          "jj show *" = "allow";
          "jj status" = "allow";
          "jj status *" = "allow";
          "jq *" = "allow";
          "ls" = "allow";
          "ls *" = "allow";
          "mkdir *" = "allow";
          "nl *" = "allow";
          "nix-locate *" = "allow";
          "ouch *" = "allow";
          "paste *" = "allow";
          "printf *" = "allow";
          "pwd" = "allow";
          "realpath *" = "allow";
          "rg *" = "allow";
          "seq *" = "allow";
          "sort *" = "allow";
          "tail *" = "allow";
          "tokei *" = "allow";
          "touch *" = "allow";
          "tr *" = "allow";
          "uniq *" = "allow";
          "wc *" = "allow";
          "which *" = "allow";
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
          "${config.home.homeDirectory}/.ssh/**" = "deny";
          "${config.home.homeDirectory}/.gnupg/**" = "deny";
          "${config.home.homeDirectory}/.config/sops/**" = "deny";
          "${config.home.homeDirectory}/Projects/ref/**" = "allow";
        };
        external_directory = {
          "/tmp/opencode/**" = "allow";
        };
        webfetch = "allow";
        websearch = "allow";
      };
      plugin = [
        "${pkgs.caveman}/src/plugins/opencode"
      ];
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
      improve-architecture = ./commands/improve-architecture.md;
      onboard = ./commands/onboard.md;
      pr = ./commands/pr.md;
      readme = ./commands/readme.md;
      review = ./commands/review.md;
      review-embedded = ./commands/review-embedded.md;
      write-tests = ./commands/write-tests.md;
    };
    skills = {
      architecture-design = ./skills/architecture-design;
      caveman = "${pkgs.caveman}/skills/caveman";
      context7-cli = "${pkgs.ctx7}/skills/context7-cli";
      debugging-and-error-investigation = ./skills/debugging-and-error-investigation;
      interview-me = ./skills/interview-me;
      jj = ./skills/jj;
      nix = ./skills/nix;
      pueue = ./skills/pueue;
    };
  };
}
