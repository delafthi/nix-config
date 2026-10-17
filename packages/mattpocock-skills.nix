{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  installAgentSkills,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mattpocock-skills";
  version = "1.3.1";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/mAmj7QFdyOWhLmy3Rt2/Hfsh5qwirTRax7hmQffFdo=";
  };

  nativeBuildInputs = [ installAgentSkills ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Skills for Real Engineers. Straight from my .agents directory";
    homepage = "https://www.aihero.dev/skills";
    changelog = "https://github.com/mattpocock/skills/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [ mit ];
    maintainers = [ lib.maintainers.delafthi ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
