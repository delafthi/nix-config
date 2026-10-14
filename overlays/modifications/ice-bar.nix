final: prev:
prev.ice-bar.overrideAttrs (
  finalAttrs: _previousAttrs: {
    version = "0.11.30";
    src = final.fetchurl {
      url = "https://github.com/cavaldos/Ice/releases/download/${finalAttrs.version}/Ice.zip";
      hash = "sha256-mf3tC2h4IYymyy0VRnVHVNjlVZ7zbq97UeqJ/dkj5Fc=";
    };
  }
)
