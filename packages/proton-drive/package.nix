{
  lib,
  stdenvNoCC,
  _7zz,
  common-updater-scripts,
  curl,
  fetchurl,
  jq,
  writeShellScript,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "proton-drive";
  version = "2.11.5";

  src = finalAttrs.passthru.sources.${stdenvNoCC.hostPlatform.system};

  sourceRoot = ".";

  nativeBuildInputs = [ _7zz ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -R "./Proton Drive.app" $out/Applications

    runHook postInstall
  '';

  passthru = {
    sources = {
      "aarch64-darwin" = fetchurl {
        url = "https://proton.me/download/drive/macos/${finalAttrs.version}/ProtonDrive-${finalAttrs.version}.dmg";
        hash = "sha256-+sl3pexI1EcqO7Djw57k69jz1/doSnNAgHXi5qQp0n8=";
      };
      "x86_64-darwin" = finalAttrs.passthru.sources."aarch64-darwin";
    };
    updateScript = writeShellScript "update-proton-drive" ''
      set -o errexit
      export PATH="${
        lib.makeBinPath [
          curl
          jq
          common-updater-scripts
        ]
      }"
      NEW_VERSION=$(curl --silent https://proton.me/download/drive/macos/version.json | jq -r '[.Releases[] | select(.CategoryName == "Stable")] | first | .Version')
      if [[ "${finalAttrs.version}" = "$NEW_VERSION" ]]; then
          echo "The new version is the same as the old version."
          exit 0
      fi
      for platform in ${lib.escapeShellArgs finalAttrs.meta.platforms}; do
        update-source-version "proton-drive" "$NEW_VERSION" --ignore-same-version --source-key="sources.$platform"
      done
    '';
  };

  meta = {
    description = "Official Proton Drive app for macOS";
    homepage = "https://proton.me/drive";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.delafthi ];
    platforms = lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
