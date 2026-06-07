{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (_finalAttrs: {
  pname = "mattpocock-skills";
  version = "0-unstable-2026-06-07";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "be55a7970319ede7965edbb02b5e41cba1ca82c9";
    sha256 = "sha256-7CjfMl1xwTIiz2wPxikV+f84r3f9xKm/BC+cJ3Gfzcw=";
  };

  installPhase = ''
    cp -r . $out
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Skills for Real Engineers";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.delafthi ];
    platforms = lib.platforms.all;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
})
