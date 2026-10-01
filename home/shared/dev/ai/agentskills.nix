{ pkgs, ... }:
{
  programs.agentskills = {
    enable = true;
    skills = {
      architecture-design = ./skills/architecture-design;
      caveman = "${pkgs.caveman}/share/skills/caveman/caveman";
      code-review = ./skills/code-review;
      context7-cli = "${pkgs.ctx7}/share/skills/ctx7/context7-cli";
      debugging-and-error-investigation = ./skills/debugging-and-error-investigation;
      interview-me = ./skills/interview-me;
      jj = ./skills/jj;
      nix = ./skills/nix;
      pueue = ./skills/pueue;
      skill-authoring = ./skills/skill-authoring;
      technical-writing = "${pkgs.cursorPlugins.pstack}/share/skills/cursorPlugins-pstack/technical-writing";
      unslop = "${pkgs.cursorPlugins.pstack}/share/skills/cursorPlugins-pstack/unslop";
    };

  };
}
