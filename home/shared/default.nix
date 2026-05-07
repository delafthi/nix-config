{
  imports = [
    ./apps
    ./dev
    ./security
    ./settings
    ./nix.nix
    ./user-dirs.nix
    ./user.nix
  ];

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
}
