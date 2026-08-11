{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      set -g fish_prompt_pwd_dir_length 3
    '';
    functions = {
      fish_title.body = "prompt_pwd";
    };
    plugins = [
      {
        name = "autopair";
        inherit (pkgs.fishPlugins.autopair-fish) src;
      }
      {
        name = "foreign-env";
        inherit (pkgs.fishPlugins.foreign-env) src;
      }
    ];
  };
}
