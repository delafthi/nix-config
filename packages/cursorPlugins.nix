{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  installAgentSkills,
  nix-update-script,
}:
let
  version = "0-unstable-2026-10-26";

  mkCursorPlugin =
    plugin:
    stdenvNoCC.mkDerivation (_finalAttrs: {
      pname = "cursorPlugins-${plugin}";
      inherit version;

      # Every plugin owns the same fetchFromGitHub (same repo/rev, so the same
      # store path, fetched once). A plugin's src must be a fetcher for tools
      # like nix-update to see rev/hash; the plugin dir is picked via
      # sourceRoot.
      src = fetchFromGitHub {
        owner = "cursor";
        repo = "plugins";
        rev = "99b609a72323b70204eab407c622f436e858e112";
        hash = "sha256-ccSz2dGaXlo69t6A7qn2xQ2uLPjQ2OqSGV2fjDEQ3Bc=";
      };
      # sourceRoot = "source/<plugin>": the fetchFromGitHub src unpacks to source/.
      sourceRoot = "source/${plugin}";

      # installAgentSkills installs every **/SKILL.md in the plugin dir to
      # $out/share/skills/$pname/<skill>/.
      nativeBuildInputs = [ installAgentSkills ];

      passthru.updateScript = nix-update-script {
        extraArgs = [
          "--flake"
          "--version=branch"
        ];
      };

      meta = {
        description = "Cursor plugin specification and official plugins — ${plugin}";
        homepage = "https://github.com/cursor/plugins";
        license = lib.licenses.mit;
        maintainers = [ lib.maintainers.delafthi ];
        platforms = lib.platforms.all;
        sourceProvenance = [ lib.sourceTypes.fromSource ];
      };
    });
in
lib.genAttrs [
  "advisor"
  "agent-compatibility"
  "cli-for-agent"
  "continual-learning"
  "create-plugin"
  "cursor-sdk"
  "cursor-team-kit"
  "docs-canvas"
  "dyl-stack"
  "grok-voice"
  "orchestrate"
  "origin-apps"
  "pr-review-canvas"
  "pstack"
  "ralph-loop"
  "teaching"
  "thermos"
] mkCursorPlugin
