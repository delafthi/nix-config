{
  home.sesionVariables = {
    NIXOS_OZONE_WL = "1";
  };
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      bind = [
        "$mod, B, exec, zen"  
      ];
    };
  };
}
