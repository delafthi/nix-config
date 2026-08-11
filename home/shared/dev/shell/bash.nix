{
  programs.bash = {
    enable = true;
    historyControl = [
      "ignoredups"
      "ignorespace"
    ];
    shellOptions = [
      "autocd"
      "cdspell"
      "cmdhist"
      "dotglob"
      "histappend"
      "expand_aliases"
      "checkwinsize"
    ];
    initExtra = ''
      # bash has no native fish_title equivalent; PROMPT_COMMAND is the
      # analog, but starship manages the prompt and PROMPT_COMMAND ordering
      # is fragile. starship's precmd invokes $starship_precmd_user_func
      # (a variable, unlike fish's function) once per prompt, so it is a
      # guaranteed hook to set the window title.
      set_title() {
        printf '\033]0;%s\007' "$(starship module directory | sed 's/\x1b\[[0-9;]*m//g' | xargs)"
      }
      starship_precmd_user_func="set_title"
    '';
  };
}
