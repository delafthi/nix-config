{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
  makeBinaryWrapper,
  writeShellScript,
  curl,
  gnugrep,
  gnused,
  coreutils,
  common-updater-scripts,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "blender-bin";
  version = "5.1.1";

  src =
    finalAttrs.passthru.sources.${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");

  sourceRoot = ".";

  nativeBuildInputs = [
    _7zz
    makeBinaryWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    mv Blender/Blender.app $out/Applications/
    makeBinaryWrapper "$out/Applications/Blender.app/Contents/MacOS/Blender" "$out/bin/blender"

    runHook postInstall
  '';

  passthru = {
    sources = {
      "aarch64-darwin" = fetchurl {
        url = "https://download.blender.org/release/Blender${lib.versions.majorMinor finalAttrs.version}/blender-${finalAttrs.version}-macos-arm64.dmg";
        hash = "sha256-/2IZs6qrTZrfVIuaMrOzF2T+dAtsdB0WZgxcD0/+mEE=";
      };
    };
    updateScript = writeShellScript "blender-bin-update-script" ''
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

      series=$(curl -s "https://download.blender.org/release/" \
        | grep -oE 'Blender[0-9]+\.[0-9]+/' \
        | sed -E 's:Blender(.*)/:\1:' \
        | sort -V \
        | tail -n1)

      new_version=$(curl -s "https://download.blender.org/release/Blender''${series}/" \
        | grep -oE 'blender-[0-9]+\.[0-9]+\.[0-9]+-macos-arm64\.dmg' \
        | sed -E 's/blender-(.*)-macos-arm64\.dmg/\1/' \
        | sort -V \
        | tail -n1)

      if [[ "${finalAttrs.version}" = "$new_version" ]]; then
        echo "blender-bin is already at the latest version $new_version."
        exit 0
      fi

      for platform in ${lib.escapeShellArgs finalAttrs.meta.platforms}; do
        update-source-version "blender-bin" "$new_version" \
          --ignore-same-version \
          --source-key="sources.$platform"
      done
    '';
  };

  meta = {
    description = "Free and open source 3D creation suite";
    homepage = "https://www.blender.org/";
    changelog = "https://www.blender.org/download/releases/${lib.versions.majorMinor finalAttrs.version}/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.delafthi ];
    platforms = builtins.attrNames finalAttrs.passthru.sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "blender";
  };
})
