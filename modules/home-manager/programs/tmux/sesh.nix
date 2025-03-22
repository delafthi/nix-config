{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      fzf
      sesh
      zoxide
    ];
    shellAliases = {
      s = "sesh connect \"$(
          sesh list --icons | fzf \
            --no-sort --ansi --border-label ' sesh ' --prompt '󱒔 ' \
            --header 'C-p  projects C-s sessions C-x zoxide C-d tmux kill' \
            --bind 'ctrl-p:change-prompt(󱒔 )+reload(sesh list --icons)' \
            --bind 'ctrl-s:change-prompt(󰆍 )+reload(sesh list -t --icons)' \
            --bind 'ctrl-x:change-prompt(󰉋 )+reload(sesh list -z --icons)' \
            --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
            --preview-window 'right:55%' \
            --preview 'sesh preview {}'
        )\"";
    };
  };
  xdg.configFile."sesh/sesh.toml".source = ./sesh.toml;
}
