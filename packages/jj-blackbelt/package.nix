{
  lib,
  stdenvNoCC,
  bun,
  writableTmpDirAsHomeHook,
}:
let
  node_modules = stdenvNoCC.mkDerivation {
    pname = "jj-blackbelt-node_modules";
    version = "0.1.0";

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

    outputHash = "sha256-EAnytwbAJPe7zT8hYGP9F1m4EcojT7UoRpT4G2dHv2s=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  manifest = builtins.toFile "package.json" (
    builtins.toJSON {
      name = "jj-blackbelt";
      type = "module";
      main = "./dist/index.js";
    }
  );
in
stdenvNoCC.mkDerivation {
  pname = "jj-blackbelt";
  version = "0.1.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./plugin.ts
      ./package.json
      ./bun.lock
    ];
  };

  nativeBuildInputs = [
    bun
    writableTmpDirAsHomeHook
  ];

  configurePhase = ''
    runHook preConfigure

    cp -R ${node_modules}/node_modules .

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    # unbash is bundled into the output; @opencode-ai/plugin is a type-only
    # import and stays external so the plugin uses the host-provided package.
    bun build plugin.ts \
      --outfile dist/index.js \
      --target node \
      --external @opencode-ai/plugin

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -R dist $out/dist
    install -Dm644 ${manifest} $out/package.json

    runHook postInstall
  '';

  meta = {
    description = "OpenCode plugin that blocks git commands and suggests jj equivalents";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.delafthi ];
    platforms = lib.platforms.all;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
}
