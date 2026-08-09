{
  lib,
  osConfig,
  ...
}:
lib.mkIf osConfig.system.gui.enable {
  targets.darwin.defaults."com.apple.GameController".homeButtonLongPressAction = 0;

}
