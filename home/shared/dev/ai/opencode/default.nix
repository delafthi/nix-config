{ pkgs, ... }:
{
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    context = ''
      Terse like caveman. Technical substance exact. Only fluff die.
      Drop: articles, filler (just/really/basically), pleasantries, hedging.
      Fragments OK. Short synonyms. Code unchanged.
      Pattern: [thing] [action] [reason]. [next step].
      ACTIVE EVERY RESPONSE. No revert after many turns. No filler drift.
      Code/commits/PRs: normal. Off: "stop caveman" / "normal mode".

      ## Version Control

      - Prefer `jj` over `git`. Use `jj` commands by default.
      - Key commands: `jj new` (new change), `jj describe` (set message), `jj squash` (amend into parent), `jj log` (history), `jj diff` (show changes).

      ## External Actions

      - NEVER post, push, publish, send, or otherwise externally share anything unless explicitly instructed to do so.
    '';
    settings = {
      autoupdate = false;
    };
    tui = {
      keybinds = {
        session_new = "<leader>c";
        session_compact = "<leader>C";
        session_child_cycle = "<leader>n";
        session_child_cycle_reverse = "<leader>p";
      };
    };
    agents = {
      investigator = ./agents/investigator.md;
      reviewer = ./agents/reviewer.md;
    };
    commands = {
      codedocs = ./commands/codedocs.md;
      commit = ./commands/commit.md;
      diagnose = ''
        ---
        description: Diagnose a bug or performance regression
        agent: investigator
        ---
        $ARGUMENTS

        @~/.config/opencode/skills/diagnose/SKILL.md
      '';
      grill-me = ''
        ---
        description: Stress-test a plan against the domain model and documented decisions
        agent: investigator
        ---
        $ARGUMENTS

        @~/.config/opencode/skills/grill-me/SKILL.md
      '';
      improve-codebase-architecture = ''
        ---
        description: Find and apply architecture improvements in the codebase
        agent: build
        ---
        $ARGUMENTS

        @~/.config/opencode/skills/improve-codebase-architecture/SKILL.md
      '';
      onboard = ./commands/onboard.md;
      pr = ./commands/pr.md;
      readme = ./commands/readme.md;
      review = ./commands/review.md;
      write-tests = ./commands/write-tests.md;
    };
    skills = {
      caveman = "${pkgs.caveman}/skills/caveman";
      diagnose = "${pkgs.mattpocock-skills}/skills/engineering/diagnose";
      grill-me = "${pkgs.mattpocock-skills}/skills/engineering/grill-with-docs";
      improve-codebase-architecture = "${pkgs.mattpocock-skills}/skills/engineering/improve-codebase-architecture";
      jj = ./skills/jj;
    };
  };
}
