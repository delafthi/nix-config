{ pkgs, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      curl
      gavin-bc
      gawk
      git
      gnugrep
      gnused
      gnutar
      uutils-coreutils-noprefix
      uutils-diffutils
      uutils-findutils
      vim
    ];
  };
}
