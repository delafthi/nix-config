{ pkgs, ... }:
{
  imports = [
    ./llama-cpp.nix
    ./opencode
  ];
  home.packages = with pkgs; [
    ctx7
  ];
}
