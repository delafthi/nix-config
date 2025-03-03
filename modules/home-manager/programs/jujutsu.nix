{pkgs}: {
  home.packages = with pkgs; [
    difftastic
  ];
  programs.jujutsu = {
    enable = true;
    settings = {
      aliases = {
        br = "branch";
        n = "new";
      };
      signing = {
        backend = "gpg";
        key = "F28424F9874E6696";
        sign-all = true;
      };
      template-aliases = {
        "format_timestamp(timestamp)" = "timestamp.ago()";
      };
      ui = {
        default-command = "log";
        tool = ["difft" "--color=always" "$left" "$right"];
      };
      user = {
        name = "Thierry Delafontaine";
        email = "thierry@delafontaine.xyz";
      };
    };
  };
}
