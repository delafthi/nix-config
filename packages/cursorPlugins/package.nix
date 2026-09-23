{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  installAgentSkills,
  nix-update-script,
}:
let
  version = "0-unstable-2026-09-22";

  src = fetchFromGitHub {
    owner = "cursor";
    repo = "plugins";
    rev = "53e579f1481697931fc44f5445171397cfa2b24b";
    sha256 = "sha256-HR6/Y53GQVbtSqIBHWaLB9WHLLYfVdE2Sn602kgLSpw=";
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

      passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

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
