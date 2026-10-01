{ pkgs, ... }:
{
  imports = [
    ./opencode
    ./agentskills.nix
    ./llama-cpp.nix
  ];
  home.packages = with pkgs; [
    ctx7
  ];
}
