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
  version = "3.0.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchurl {
    url = "https://proton.me/download/drive/macos/${finalAttrs.version}/ProtonDrive-${finalAttrs.version}.dmg";
    hash = "sha256-uMK4uGucUmwCwye9J9JbJ5zmDtlhVPTtMEQC8ukRZH8=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ _7zz ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -R "./Proton Drive.app" $out/Applications

    runHook postInstall
  '';

  passthru.updateScript = writeShellScript "update-proton-drive" ''
    set -euo pipefail
    export PATH="${
      lib.makeBinPath [
        curl
        jq
        common-updater-scripts
      ]
    }"

    new_version=$(curl --silent https://proton.me/download/drive/macos/version.json \
      | jq -r '[.Releases[] | select(.CategoryName == "Stable")] | first | .Version')

    if [[ "${finalAttrs.version}" = "$new_version" ]]; then
        echo "proton-drive is already at the latest version $new_version."
        exit 0
    fi

    update-source-version "proton-drive" "$new_version" \
      --ignore-same-version
  '';

  meta = {
    description = "Official Proton Drive app for macOS";
    homepage = "https://proton.me/drive";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.delafthi ];
    platforms = lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
