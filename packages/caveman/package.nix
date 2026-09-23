{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  installAgentSkills,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "caveman";
  version = "2.7.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "JuliusBrussee";
    repo = "caveman";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-dsGzPscjy7FfaovfYML2q+RmuBJwwEJ9sjeHi+Niv6Y=";
  };

  # installSkill() is provided by installAgentSkills; dontInstallAgentSkills
  # disables the blanket **/SKILL.md glob (it would collide on skill names
  # that exist both under skills/ and plugins/) in favor of explicit calls.
  nativeBuildInputs = [ installAgentSkills ];
  dontInstallAgentSkills = 1;

  installPhase = ''
    runHook preInstall

    # Skills -> $out/share/skills/caveman/<skill>/ (agentskills layout).
    for skill in "$src"/skills/*/; do
      [ -f "$skill/SKILL.md" ] || continue
      installSkill "$skill"
    done

    # Plugin, hooks, and rules -> $out/share/caveman/.
    mkdir -p "$out/share/caveman/plugins/opencode" "$out/share/caveman/hooks" "$out/share/caveman/rules"
    cp -r "$src/src/plugins/opencode"/. "$out/share/caveman/plugins/opencode/"
    cp "$src/src/hooks/caveman-config.js" "$out/share/caveman/plugins/opencode/caveman-config.cjs"
    cp "$src/src/hooks/caveman-parse.js" "$out/share/caveman/plugins/opencode/caveman-parse.cjs"
    cp "$src"/src/hooks/*.js "$out/share/caveman/hooks/"
    cp "$src"/src/rules/*.md "$out/share/caveman/rules/"

    # plugin.js probes <pluginDir>/../../skills/caveman/SKILL.md, so expose
    # the installed skill at the matching parent-dir-relative path.
    mkdir -p "$out/share/caveman/skills"
    ln -s "$out/share/skills/caveman/caveman" "$out/share/caveman/skills/caveman"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Claude Code plugin that enforces caveman-style communication";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.delafthi ];
    platforms = lib.platforms.all;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    changelog = "https://github.com/JuliusBrussee/caveman/releases/tag/v${finalAttrs.version}";
  };
})
