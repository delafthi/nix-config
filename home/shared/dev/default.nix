{ pkgs, ... }:
{
  imports = [
    ./ai
    ./lang
    ./shell
    ./vcs
    ./bat.nix
    ./btop.nix
    ./direnv.nix
    ./editorconfig.nix
    ./eza.nix
    ./fd.nix
    ./television.nix
    ./ghostty.nix
    ./helix.nix
    ./nix-index.nix
    ./pandoc.nix
    ./pueue.nix
    ./podman.nix
    ./ripgrep.nix
    ./tealdeer.nix
    ./tmux.nix
    ./yazi.nix
    ./zoxide.nix
  ];
  home = {
    extraOutputsToInstall = [ "man" ];
    packages = with pkgs; [
      asciinema
      ast-grep
      charm-freeze
      curl
      dust
      ffmpeg
      fq
      glow
      gnutar
      gum
      hexyl
      hyperfine
      imagemagick
      jaq
      just
      ouch
      p7zip
      pv
      procs
      sd
      silicon
      svu
      tesseract
      tokei
      typos
      unrar
      unzip
      usbutils
      vhs
      watch
      zip
    ];
    shellAliases = {
      jq = "jaq";
      sg = "ast-grep";
      strace = "strace -yy";
    };
  };
}
