{
  lib,
  stdenv,
  bun,
  darwin,
  fetchFromGitHub,
  git,
  installAgentSkills,
  makeBinaryWrapper,
  nodejs,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:
let
  node_modules =
    finalAttrs:
    stdenv.mkDerivation {
      pname = "plannotator-node_modules";
      inherit (finalAttrs) version src;

      __structuredAttrs = true;
      strictDeps = true;

      impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
        "GIT_PROXY_COMMAND"
        "SOCKS_SERVER"
      ];

      nativeBuildInputs = [
        bun
        writableTmpDirAsHomeHook
      ];

      dontConfigure = true;

      buildPhase = ''
        runHook preBuild

        # Drop the 7-day minimumReleaseAge gate: it is a live-registry check
        # that makes builds nondeterministic in a sandbox.
        sed -i '/minimumReleaseAge/d' bunfig.toml

        export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
        bun install \
          --cpu="*" \
          --frozen-lockfile \
          --filter ./ \
          --filter ./apps/hook \
          --filter ./apps/review \
          --filter ./apps/opencode-plugin \
          --filter ./packages/ai \
          --filter ./packages/core \
          --filter ./packages/editor \
          --filter ./packages/review-editor \
          --filter ./packages/server \
          --filter ./packages/shared \
          --filter ./packages/ui \
          --ignore-scripts \
          --no-progress \
          --os="*"

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        find . -type d -name node_modules -exec cp -R --parents {} $out \;

        # Windows executables are never executed on Linux/Darwin; dropping
        # them keeps the output reproducible and avoids quarantined 7za.exe.
        find $out -type f -name '*.exe' -delete

        runHook postInstall
      '';

      dontFixup = true;

      outputHash = "sha256-LV7yphVZ6UgYz8ux9cy43GbRBwj3yMc9iBmqC0l01/8=";
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
    };

  sem = rustPlatform.buildRustPackage {
    pname = "sem";
    version = "0.8.0";

    __structuredAttrs = true;
    strictDeps = true;

    nativeBuildInputs = [
      git
      pkg-config
      writableTmpDirAsHomeHook
    ];

    buildInputs = [
      openssl
    ];

    src = fetchFromGitHub {
      owner = "Ataraxy-Labs";
      repo = "sem";
      tag = "v0.8.0";
      hash = "sha256-X2S6BBb7YVur9iAaCzSNEmP296V2Yy3PK+QujNMSfsI=";
    };

    cargoHash = "sha256-XumNe/xOlOOepacgF+aheEZwzGIlakutlxLlzx0Qjwo=";

    postUnpack = ''
      sourceRoot="$sourceRoot/crates"
    '';

    meta = {
      description = "Semantic version control CLI used by Plannotator for code review";
      homepage = "https://github.com/Ataraxy-Labs/sem";
      license = lib.licenses.mit;
      maintainers = [ lib.maintainers.delafthi ];
      platforms = lib.platforms.unix;
      mainProgram = "sem";
    };
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "plannotator";
  version = "0.27.24";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "backnotprop";
    repo = "plannotator";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bMZhTKrp02jD3WPDuet3mj7sN542Pai4yTjPG+61VjA=";
  };

  nativeBuildInputs = [
    bun
    installAgentSkills
    nodejs
    makeBinaryWrapper
    writableTmpDirAsHomeHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.sigtool
  ];

  configurePhase = ''
    runHook preConfigure

    cp -R ${finalAttrs.passthru.node_modules}/. .
    patchShebangs node_modules
    patchShebangs packages/*/node_modules

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    bun run build:review
    bun run build:hook
    bun run build:opencode
    bun build apps/hook/server/index.ts --compile --no-compile-autoload-bunfig \
      --define "__CLI_VERSION__=\"${finalAttrs.version}\"" \
      --outfile plannotator

    runHook postBuild
  '';

  dontInstallAgentSkills = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 plannotator $out/bin/plannotator
    wrapProgram $out/bin/plannotator \
      --prefix PATH : ${
        lib.makeBinPath [
          git
          nodejs
          sem
        ]
      }

    # Skills -> $out/share/skills/plannotator/<skill>/ (agentskills layout).
    for skill in apps/skills/{core,extra}/*/; do
      [ -f $skill/SKILL.md ] || continue
      installSkill $skill
    done

    # Plugin and commands -> $out/share/plannotator/.
    mkdir -p $out/share/plannotator/plugins/opencode $out/share/plannotator/commands/opencode
    cp -r "$src"/apps/opencode-plugin/.  $out/share/plannotator/plugins/opencode/
    cp -r apps/opencode-plugin/commands $out/share/plannotator/commands/opencode

    runHook postInstall
  '';

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    codesign --force --sign - $out/bin/.plannotator-wrapped
  '';

  dontStrip = true;

  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];
  doInstallCheck = true;

  passthru = {
    node_modules = node_modules finalAttrs;
    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage"
        "node_modules"
      ];
    };
  };

  meta = {
    description = "AI plan review with interactive visual annotation";
    homepage = "https://plannotator.ai";
    changelog = "https://github.com/backnotprop/plannotator/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [
      asl20
      mit
    ];
    maintainers = [ lib.maintainers.delafthi ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
      "aarch64-darwin"
    ];
    mainProgram = "plannotator";
  };
})
