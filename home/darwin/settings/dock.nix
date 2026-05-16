{
  config,
  lib,
  osConfig,
  ...
}:
lib.mkIf osConfig.system.gui.enable {
  targets.darwin.defaults."com.apple.dock" = {
    autohide = true;
    mineffect = "scale";
    minimize-to-application = true;
    orientation = "bottom";
    persistent-apps =
      map
        (app: {
          tile-data.file-data = {
            _CFURLString = "file://${app}/";
            _CFURLStringType = 15;
          };
        })
        [
          "${config.home.homeDirectory}/Applications/Home Manager Apps/Zen Browser (Beta).app"
          "${config.home.homeDirectory}/Applications/Home Manager Apps/Proton Mail.app"
          "${config.home.homeDirectory}/Applications/Home Manager Apps/Proton Pass.app"
          "/System/Applications/Music.app"
          "/Applications/Things3.app"
          "${config.home.homeDirectory}/Applications/Home Manager Apps/Obsidian.app"
          "${config.home.homeDirectory}/Applications/Home Manager Apps/Ghostty.app"
        ];
    show-recents = false;
    showhidden = true;
    tilesize = 60;
  };
}
