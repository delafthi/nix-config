{pkgs}: {
  programs.gnome-shell = {
    enable = true;
    extensions = with pkgs.gnomeExtensions; [
      {package = keep-awake;}
      {package = user-themes;}
      {package = dash-to-dock;}
      {package = blur-my-shell;}
    ];
  };
}
