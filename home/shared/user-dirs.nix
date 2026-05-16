{
  config,
  pkgs,
  user,
  ...
}:
{
  home = {
    homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${user}" else "/home/${user}";
    preferXdgDirectories = true;
  };
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      extraConfig.MOVIES = "${config.home.homeDirectory}/Movies";
      setSessionVariables = true;
      videos = "${config.home.homeDirectory}/Movies";
    };
  };
}
