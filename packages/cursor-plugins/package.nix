{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gnused,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (_finalAttrs: {
  pname = "cursor-plugins";
  version = "0-unstable-2026-09-04";

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [ gnused ];

  # Scope unslop to file content: keep it away from chat responses (caveman owns those).
  postPatch = ''
    substituteInPlace pstack/skills/unslop/SKILL.md \
      --replace-fail \
        'description: Cut AI tells from any writing. Must always apply.' \
        'description: Cut AI tells from written artifacts. Use when writing or editing file content (docs, prose, comments, commit messages). Do not apply to chat responses.'
  '';

  src = fetchFromGitHub {
    owner = "cursor";
    repo = "plugins";
    rev = "93b00b89ef425a9c1bac0d0b317dfc49c930ac99";
    sha256 = "sha256-wA+B7ho81xzhoLgg+30fX9Cx1RvEF2N4qsQZexSZT0s=";
  };

  installPhase = ''
    cp -r . $out
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Cursor plugin specification and official plugins";
    homepage = "https://github.com/cursor/plugins";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.delafthi ];
    platforms = lib.platforms.all;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
})
