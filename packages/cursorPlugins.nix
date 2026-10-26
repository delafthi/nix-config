{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  installAgentSkills,
  nix-update-script,
}:
let
  version = "0-unstable-2026-10-26";

  src = fetchFromGitHub {
    owner = "cursor";
    repo = "plugins";
    rev = "99b609a72323b70204eab407c622f436e858e112";
    sha256 = "sha256-ccSz2dGaXlo69t6A7qn2xQ2uLPjQ2OqSGV2fjDEQ3Bc=";
  };

  # Auto-detect cursor plugins: top-level repo dirs that directly contain a skills/ dir.
  cursorPlugins = lib.filterAttrs (
    name: type: type == "directory" && builtins.pathExists "${src}/${name}/skills"
  ) (builtins.readDir src);

  mkCursorPlugin =
    plugin:
    stdenvNoCC.mkDerivation (_finalAttrs: {
      pname = "cursorPlugins-${plugin}";
      inherit version;

      src = "${src}/${plugin}";

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
lib.mapAttrs (name: _: mkCursorPlugin name) cursorPlugins
