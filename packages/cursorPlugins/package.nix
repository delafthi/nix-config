{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  installAgentSkills,
  nix-update-script,
}:
let
  version = "0-unstable-2026-10-13";

  src = fetchFromGitHub {
    owner = "cursor";
    repo = "plugins";
    rev = "1dcc2bacde73ddd284803b7af28164d0436198fc";
    sha256 = "sha256-TxT+i3gTHqonghhTnJvvM9XpXBeKUp0880iH5aO4SGo=";
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
