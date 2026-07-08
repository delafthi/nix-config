{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  writeShellScript,
  curl,
  gnugrep,
  gnused,
  coreutils,
  common-updater-scripts,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "crossover";
  version = "26.2.0";

  __structuredAttrs = true;
  strictDeps = true;

  src =
    finalAttrs.passthru.sources.${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -R CrossOver.app $out/Applications/

    runHook postInstall
  '';

  passthru = {
    sources = {
      "aarch64-darwin" = fetchurl {
        url = "https://media.codeweavers.com/pub/crossover/cxmac/demo/crossover-${finalAttrs.version}.zip";
        hash = "sha256-qzloCSeg2cMTytJ/7TPdFaeZvkDJO/xDK+9wUYrxCqQ=";
      };
      "x86_64-darwin" = finalAttrs.passthru.sources."aarch64-darwin";
    };
    updateScript = writeShellScript "crossover-update-script" ''
      set -euo pipefail
      export PATH="${
        lib.makeBinPath [
          curl
          gnugrep
          gnused
          coreutils
          common-updater-scripts
        ]
      }"

      new_version=$(curl -s "https://www.codeweavers.com/xml/versions/cxmac.xml" \
        | grep -oE 'crossover-[0-9]+\.[0-9]+\.[0-9]+\.zip' \
        | sed -E 's/crossover-(.*)\.zip/\1/' \
        | head -n1)

      if [[ "${finalAttrs.version}" = "$new_version" ]]; then
        echo "crossover is already at the latest version $new_version."
        exit 0
      fi

      for platform in ${lib.escapeShellArgs finalAttrs.meta.platforms}; do
        update-source-version "crossover" "$new_version" \
          --ignore-same-version \
          --source-key="sources.$platform"
      done
    '';
  };

  meta = {
    description = "Run Windows applications on macOS without a Windows license";
    homepage = "https://www.codeweavers.com/crossover";
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.delafthi ];
    platforms = builtins.attrNames finalAttrs.passthru.sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
