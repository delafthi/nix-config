{
  lib,
  stdenv,
  bun,
  darwin,
  fetchFromGitHub,
  git,
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
          --filter ./apps/inbox \
          --filter ./apps/review \
          --filter ./packages \
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

      outputHash = "sha256-0WRrMrSTCGJwBwEGaMsTxD9gOnTUSkTRk6wJy9eV2Qs=";
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
  version = "0.28.31";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "backnotprop";
    repo = "plannotator";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iCPaPlddFewj9JL5CEs48BW4D6p+j3RXyNbMc16+r6Q=";
  };

  node_modules = node_modules finalAttrs;

  nativeBuildInputs = [
    bun
    nodejs
    makeBinaryWrapper
    writableTmpDirAsHomeHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.sigtool
  ];

  configurePhase = ''
    runHook preConfigure

    cp -R $node_modules/. .
    patchShebangs node_modules
    patchShebangs packages/*/node_modules

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    bun run build:review
    bun run build:hook
    bun build apps/hook/server/index.ts --compile --no-compile-autoload-bunfig \
      --define "__CLI_VERSION__=\"${finalAttrs.version}\"" \
      --outfile plannotator
    bun build apps/paste-service/targets/bun.ts --compile --no-compile-autoload-bunfig \
      --outfile plannotator-paste

    runHook postBuild
  '';

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
    install -Dm755 plannotator-paste $out/bin/plannotator-paste

    runHook postInstall
  '';

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    codesign --force --sign - $out/bin/.plannotator-wrapped
    codesign --force --sign - $out/bin/plannotator-paste
  '';

  dontStrip = true;

  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];
  doInstallCheck = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--subpackage"
      "node_modules"
    ];
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
