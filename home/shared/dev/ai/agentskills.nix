{ pkgs, ... }:
{
  programs.agentskills = {
    enable = true;
    skills = {
      blast-radius = "${pkgs.cursorPlugins.pstack}/share/skills/cursorPlugins-pstack/blast-radius";
      code-review = ./skills/code-review;
      codebase-design = "${pkgs.mattpocock-skills}/share/skills/mattpocock-skills/codebase-design";
      context7-cli = "${pkgs.ctx7}/share/skills/ctx7/context7-cli";
      correct = "${pkgs.cursorPlugins.pstack}/share/skills/cursorPlugins-pstack/correct";
      deslop = "${pkgs.cursorPlugins.cursor-team-kit}/share/skills/cursorPlugins-cursor-team-kit/deslop";
      diagnosing-bugs = "${pkgs.mattpocock-skills}/share/skills/mattpocock-skills/diagnosing-bugs";
      domain-modeling = "${pkgs.mattpocock-skills}/share/skills/mattpocock-skills/domain-modeling";
      grill-me = "${pkgs.mattpocock-skills}/share/skills/mattpocock-skills/grill-me";
      grill-with-docs = "${pkgs.mattpocock-skills}/share/skills/mattpocock-skills/grill-with-docs";
      grilling = "${pkgs.mattpocock-skills}/share/skills/mattpocock-skills/grilling";
      improve-codebase-architecture = "${pkgs.mattpocock-skills}/share/skills/mattpocock-skills/improve-codebase-architecture";
      jj = ./skills/jj;
      nix = ./skills/nix;
      prototype = "${pkgs.mattpocock-skills}/share/skills/mattpocock-skills/prototype";
      pueue = ./skills/pueue;
      research = "${pkgs.mattpocock-skills}/share/skills/mattpocock-skills/research";
      skill-authoring = ./skills/skill-authoring;
      tdd = "${pkgs.mattpocock-skills}/share/skills/mattpocock-skills/tdd";
      teach = "${pkgs.mattpocock-skills}/share/skills/mattpocock-skills/teach";
      technical-writing = "${pkgs.cursorPlugins.pstack}/share/skills/cursorPlugins-pstack/technical-writing";
      unslop = "${pkgs.cursorPlugins.pstack}/share/skills/cursorPlugins-pstack/unslop";
      verify-this = "${pkgs.cursorPlugins.cursor-team-kit}/share/skills/cursorPlugins-cursor-team-kit/verify-this";
    };

  };
}
