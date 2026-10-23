{
  config,
  pkgs,
  ...
}:
let
  rule = action: resource: effect: {
    inherit action resource effect;
  };
in
{
  home.shellAliases = {
    oc = "opencode";
  };
  programs.opencode = {
    enable = true;
    extraPackages = with pkgs; [ plannotator ];
    context = ''
      ## Glossary

      - `change`: Jujutsu change object (verb usage = normal English).
      - `rev`: Jujutsu revision selector (`@`, `@-`, `main`, `description(foo)`).
      - `bookmark`: Jujutsu bookmark, not git branch.
      - `working copy`: current mutable checkout at `@`.
      - User wording wins when explicitly overridden.

      ## Preferred tools

      - `fd` over `find`, `rg` over `grep`, `bat` over `cat`, `delta` over `diff`, `eza` over `ls`
      - `jaq` for JSON, `tokei` for metrics, `hyperfine` for benchmarks, `ouch` for archives

      ## Version Control

      - Use `jj` only, never `git`. `jj-blackbelt` blocks every `git` command,
        so `jj status || git status`-style fallbacks always get denied.
        Key commands: `jj new`, `jj describe`, `jj squash`, `jj log`, `jj diff`.

      ## Scratch

      - `/tmp/opencode` for scratch work outside workspace.

      ## Search

      - Clone reference projects to `${config.home.homeDirectory}/Projects/ref` — prefer local source over web search.

      ## Nix

      - Nix manages packages and the dev environment, not `apt`/`brew`/`pip`. A missing binary is not in the profile, not unavailable — read the `nix` skill before installing anything.
      - Projects are not necessarily Nix projects. `flake.nix`, when present, is the toolchain source of truth.

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
      update = "disable";
      username = "delafthi";
      share = "disabled";
      # Rules are ordered, the last matching rule wins. A " *" pattern also
      # matches the command without arguments, so "ls *" covers "ls".
      permissions = [
        (rule "shell" "*" "ask")
        (rule "shell" "basename *" "allow")
        (rule "shell" "bat *" "allow")
        (rule "shell" "cut *" "allow")
        (rule "shell" "date *" "allow")
        (rule "shell" "delta *" "allow")
        (rule "shell" "dirname *" "allow")
        (rule "shell" "echo *" "allow")
        (rule "shell" "eza *" "allow")
        (rule "shell" "fd *" "allow")
        (rule "shell" "fold *" "allow")
        (rule "shell" "gh pr diff *" "allow")
        (rule "shell" "gh pr list *" "allow")
        (rule "shell" "gh pr view *" "allow")
        (rule "shell" "grep *" "allow")
        (rule "shell" "head *" "allow")
        (rule "shell" "hyperfine *" "allow")
        (rule "shell" "jj bookmark list *" "allow")
        (rule "shell" "jj diff *" "allow")
        (rule "shell" "jj git remote list *" "allow")
        (rule "shell" "jj log *" "allow")
        (rule "shell" "jj root *" "allow")
        (rule "shell" "jj show *" "allow")
        (rule "shell" "jj status *" "allow")
        (rule "shell" "jaq *" "allow")
        (rule "shell" "jq *" "allow")
        (rule "shell" "ls *" "allow")
        (rule "shell" "mkdir *" "allow")
        (rule "shell" "nl *" "allow")
        (rule "shell" "nix config show *" "allow")
        (rule "shell" "nix doctor *" "allow")
        (rule "shell" "nix eval --no-write-lock-file *" "allow")
        (rule "shell" "nix flake metadata --no-write-lock-file *" "allow")
        (rule "shell" "nix flake show --no-write-lock-file *" "allow")
        (rule "shell" "nix registry list *" "allow")
        (rule "shell" "nix store ls *" "allow")
        (rule "shell" "nix store ping *" "allow")
        (rule "shell" "nix-locate *" "allow")
        (rule "shell" "ouch *" "allow")
        (rule "shell" "paste *" "allow")
        (rule "shell" "printf *" "allow")
        (rule "shell" "pueue follow *" "allow")
        (rule "shell" "pueue log *" "allow")
        (rule "shell" "pueue status *" "allow")
        (rule "shell" "pwd" "allow")
        (rule "shell" "realpath *" "allow")
        (rule "shell" "rg *" "allow")
        (rule "shell" "sed *" "allow")
        (rule "shell" "seq *" "allow")
        (rule "shell" "sort *" "allow")
        (rule "shell" "tail *" "allow")
        (rule "shell" "tokei *" "allow")
        (rule "shell" "touch *" "allow")
        (rule "shell" "tr *" "allow")
        (rule "shell" "uniq *" "allow")
        (rule "shell" "wc *" "allow")
        (rule "shell" "which *" "allow")
        (rule "read" "*" "allow")
        (rule "read" "*.env" "deny")
        (rule "read" "*.env.*" "deny")
        (rule "read" "*.env.example" "allow")
        (rule "read" "*.key" "deny")
        (rule "read" "*.pem" "deny")
        (rule "read" "*.p12" "deny")
        (rule "read" "*.pfx" "deny")
        (rule "read" "*.p8" "deny")
        (rule "read" "*.kdbx" "deny")
        (rule "read" "*.agekey" "deny")
        (rule "read" ".netrc" "deny")
        (rule "read" "id_*" "deny")
        (rule "external_directory" "*" "ask")
        (rule "external_directory" "/tmp/opencode/**" "allow")
        (rule "external_directory" "/tmp/opencode/**" "allow")
        (rule "webfetch" "*" "allow")
        (rule "websearch" "*" "allow")
      ];
      # Policies hard-deny, they override permissions and saved approvals.
      policies = [
        (rule "tool.use" "shell:sudo *" "deny")
        (rule "tool.use" "external_directory:${config.home.homeDirectory}/.ssh/*" "deny")
        (rule "tool.use" "external_directory:${config.home.homeDirectory}/.gnupg/*" "deny")
        (rule "tool.use" "external_directory:${config.home.homeDirectory}/.config/sops/*" "deny")
      ];
      references = {
        linux = {
          path = "${config.home.homeDirectory}/Projects/ref/linux";
          description = "Use when investigating Linux kernel source: syscalls, drivers, filesystems, or kernel APIs.";
        };
        nix-darwin = {
          path = "${config.home.homeDirectory}/Projects/ref/nix-darwin";
          description = "Use when looking up nix-darwin options, module definitions, or macOS system defaults.";
        };
        nixpkgs = {
          path = "${config.home.homeDirectory}/Projects/ref/nixpkgs";
          description = "Use when looking up Nix package definitions, NixOS module options, or nixpkgs library functions.";
        };
        opencode = {
          path = "${config.home.homeDirectory}/Projects/ref/opencode";
          description = "Use when working on OpenCode itself: config schema, plugins, tools, or agent behavior.";
        };
      };
      providers = {
        "llama.cpp" = {
          name = "llama-server (local)";
          package = "@opencode/ai/providers/openai-compatible";
          settings = {
            baseURL = "http://127.0.0.1:11434/v1";
          };
          models = {
            "ggml-org/gemma-4-E4B-it-GGUF:Q8_0" = {
              name = "Gemma 4 E4B-it Q8_0 (local)";
              limit = {
                context = 32768;
                output = 8192;
              };
            };
          };
        };
      };
      plugins = [
        "@dietrichgebert/ponytail"
        "${pkgs.jj-blackbelt}/share/plugins/opencode/jj-blackbelt"
        "@plannotator/opencode@latest"
      ];
      experimental = {
        todo = true;
        subagent_depth = 2;
      };
    };
    commands = {
      codedocs = ./commands/codedocs.md;
      commit = ./commands/commit.md;
      continue = ./commands/continue.md;
      grill-me = ./commands/grill-me.md;
      grill-with-docs = ./commands/grill-with-docs.md;
      handover = ./commands/handover.md;
      improve-codebase-architecture = ./commands/improve-codebase-architecture.md;
      onboard = ./commands/onboard.md;
      pr = ./commands/pr.md;
      readme = ./commands/readme.md;
      review = ./commands/review.md;
      review-embedded = ./commands/review-embedded.md;
    };
  };
}
