_final: _prev:
_prev.ice-bar.overrideAttrs (
  previousAttrs: finalAttrs: {
    version = "0.11.30";
    src = _final.fetchurl {
      url = "https://github.com/cavaldos/Ice/releases/download/${finalAttrs.version}/Ice.zip";
      hash = "sha256-mf3tC2h4IYymyy0VRnVHVNjlVZ7zbq97UeqJ/dkj5Fc=";
    };
  }
)
