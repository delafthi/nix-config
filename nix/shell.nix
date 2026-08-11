{
  mkShell,
  config,
  age,
  age-plugin-yubikey,
  bashInteractive,
  nixd,
  sops,
}:
mkShell {
  name = "default";
  inputsFrom = [ config.treefmt.build.devShell ];
  packages = [
    age
    age-plugin-yubikey
    bashInteractive
    nixd
    sops
  ];
}
