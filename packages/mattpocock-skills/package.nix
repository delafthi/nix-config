{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (_finalAttrs: {
  pname = "mattpocock-skills";
  version = "0-unstable-2026-04-03";

  src = fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "b843cb5ea74b1fe5e58a0fc23cddef9e66076fb8";
    sha256 = "sha256-qOhU5bBnT6kI8c7i0r0IyecrgLJNNPlmQtAb6qWM73Q=";
  };

  installPhase = ''
    cp -r . $out
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Skills for Real Engineers";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.delafthi ];
    platforms = lib.platforms.all;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
})
