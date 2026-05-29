{
  mkShell,
  age,
  age-plugin-yubikey,
  nixd,
  sops,
  config,
}:
mkShell {
  name = "default";
  inputsFrom = [ config.treefmt.build.devShell ];
  packages = [
    age
    age-plugin-yubikey
    nixd
    sops
  ];
}
