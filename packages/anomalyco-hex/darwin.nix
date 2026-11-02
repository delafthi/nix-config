{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
  makeBinaryWrapper,
  pname,
  version,
  meta,
  updateScript,
}:
let
  sources = {
    aarch64-darwin = fetchurl {
      url = "https://github.com/anomalyco/hex/releases/download/v${version}/hex-${version}-macos-arm64.dmg";
      hash = "sha256-xXEGlJooo9B2fMFVBc2AJji63rDBjP0GxXsTCrDZiFk=";
    };
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit pname version;
  src = sources.${stdenvNoCC.hostPlatform.system};

  # macOS package is the released dmg binary
  meta = meta // {
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    _7zz
    makeBinaryWrapper
  ];

  sourceRoot = ".";

  unpackPhase = ''
    runHook preUnpack

    7zz -snld x $src

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    mv Hex.app $out/Applications/
    makeBinaryWrapper "$out/Applications/Hex.app/Contents/MacOS/hex" "$out/bin/hex"

    runHook postInstall
  '';

  passthru = {
    inherit sources;
    updateScript = updateScript;
  };
})
