{
  lib,
  config,
  pkgs,
  tokyonight,
  ...
}: {
  imports = [
    (import ../home.nix {inherit lib config pkgs tokyonight;})
    (import ./dconf.nix {inherit lib;})
    (import ./gtk.nix {inherit config pkgs;})
    (import ./programs/gnome-shell.nix {inherit pkgs;})
    (import ./programs/ulauncher.nix {inherit pkgs;})
    (import ./services/gpg-agent.nix {inherit pkgs;})
    ./services/podman.nix
    ./services/unclutter.nix
    ./xdg.nix
  ];
  home = {
    file.Downloads.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Documents/0-inbox/downloads";
    homeDirectory = "/home/delafthi";
    pointerCursor = {
      package = pkgs.whitesur-cursors;
      gtk.enable = true;
      name = "WhiteSur Cursors";
      x11.enable = true;
    };
    packages = with pkgs; [
      ascii-draw
      blender
      brave
      godot_4
      mpv
      proton-pass
      protonmail-desktop
      protonvpn-gui
      virt-manager
    ];
    shellAliases = {
      open = "xdg-open";
    };
  };
  systemd.user.startServices = "sd-switch";
  xsession.enable = true;
}
