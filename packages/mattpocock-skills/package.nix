{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (_finalAttrs: {
  pname = "mattpocock-skills";
  version = "0-unstable-2026-05-13";

  src = fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "f304057d61d3df3c9fd992ac2b6e3833cb9325fb";
    sha256 = "sha256-jdUTec3217Bc+h5npjKOlIBHp3rhEd/sRKzDV2N7XIc=";
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
