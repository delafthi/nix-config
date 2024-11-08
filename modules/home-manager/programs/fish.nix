{ pkgs ? import <nixpkgs> { } }: {
  programs.fish = {
    enable = true;
    functions = {
      __fish_command_not_found_handler = {
        body = "__fish_default_command_not_found_handler $argv[1]";
        onEvent = "fish_command_not_found";
      };

      gitignore = "curl -sL https://www.gitignore.io/api/$argv";
    };
    interactiveShellInit = ''
      set fish_greeting
      set -g fish_key_bindings fish_vi_key_bindings
      bind -M insert \ck up-or-search
      bind -M insert \cj down-or-search
      bind -M insert \cl accept-autosuggestion
      bind -M insert \cp up-or-search
      bind -M insert \cn complete
      bind -M insert \cs pager-toggle-search
    '';
    plugins = [
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair-fish.src;
      }
      {
        name = "foreign-env";
        src = pkgs.fishPlugins.foreign-env.src;
      }
    ];
  };
}
