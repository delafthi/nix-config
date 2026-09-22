{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gnused,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (_finalAttrs: {
  pname = "cursor-plugins";
  version = "0-unstable-2026-09-22";

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
    rev = "53e579f1481697931fc44f5445171397cfa2b24b";
    sha256 = "sha256-HR6/Y53GQVbtSqIBHWaLB9WHLLYfVdE2Sn602kgLSpw=";
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
