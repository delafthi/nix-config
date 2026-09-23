_final: _prev:
_prev.ice-bar.overrideAttrs (_oldAttrs: {
  version = "0.11.28";
  src = _final.fetchurl {
    url = "https://github.com/cavaldos/Ice/releases/download/v0.11.28/Ice.zip";
    hash = "sha256-mf3tC2h4IYymyy0VRnVHVNjlVZ7zbq97UeqJ/dkj5Fc=";
  };
})
