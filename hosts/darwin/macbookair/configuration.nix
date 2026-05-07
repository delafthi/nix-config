{
  imports = [
    ../../../system/darwin
    ../../../system/shared
  ];
  environment.darwinConfig = toString ./configuration.nix;

  # https://nix-darwin.github.io/nix-darwin/manual/index.html#opt-system.stateVersion
  system.stateVersion = 6;
}
