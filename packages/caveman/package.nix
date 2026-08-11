{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "caveman";
  version = "1.10.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "JuliusBrussee";
    repo = "caveman";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-3lPEPb+hzomLLz4xfU7wQS++10gXP0UbXHXq/yluAGM=";
  };

  installPhase = ''
    cp -r . $out
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
