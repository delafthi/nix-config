{ pkgs, ... }:
{
  imports = [
    ./opencode
  ];
  home.packages = with pkgs; [
    ctx7
  ];
}
