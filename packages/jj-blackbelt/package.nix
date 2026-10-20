{
  lib,
  stdenvNoCC,
  bun,
  nodejs,
  writableTmpDirAsHomeHook,
}:
let
  node_modules =
    finalAttrs:
    stdenvNoCC.mkDerivation {
      pname = "${finalAttrs.pname}-node_modules";
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

      dontUnpack = true;
      dontConfigure = true;

      buildPhase = ''
        runHook preBuild

        cp ${./package.json} package.json
        cp ${./bun.lock} bun.lock

        export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
        bun install \
          --cpu="*" \
          --frozen-lockfile \
          --ignore-scripts \
          --no-progress \
          --os="*"

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        cp -R node_modules $out/node_modules

        runHook postInstall
      '';

      dontFixup = true;

      outputHash = "sha256-rkCeuh7TgKx42zOeZWAP0Bjcv/Nsqa1jxiqTTn2l0gI=";
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
    };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "jj-blackbelt";
  inherit ((builtins.fromJSON (builtins.readFile ./package.json))) version;

  __structuredAttrs = true;
  strictDeps = true;

  node_modules = node_modules finalAttrs;

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./src
      ./test
      ./package.json
      ./bun.lock
    ];
  };

  nativeBuildInputs = [
    bun
    nodejs
    writableTmpDirAsHomeHook
  ];

  configurePhase = ''
    runHook preConfigure

    cp -R "$node_modules"/. .
    patchShebangs node_modules

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    bun build src/index.ts \
      --outfile index.js \
      --target node

    runHook postBuild
  '';

  doCheck = true;

  checkPhase = ''
    runHook preCheck

    bun test

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/plugins/opencode/jj-blackbelt
    cp index.js $out/share/plugins/opencode/jj-blackbelt/index.js
    install -Dm644 package.json $out/share/plugins/opencode/jj-blackbelt/package.json

    runHook postInstall
  '';

  meta = {
    description = "OpenCode plugin that blocks git commands and suggests jj equivalents";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.delafthi ];
    platforms = lib.platforms.all;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
})
