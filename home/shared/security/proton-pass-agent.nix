{
  lib,
  osConfig,
  pkgs,
  ...
}:
{
  services.proton-pass-agent.enable = true;
  home.sessionVariables =
    lib.optionalAttrs (pkgs.stdenv.hostPlatform.isLinux && osConfig.system.gui.enable)
      {
        PROTON_PASS_LINUX_KEYRING = "dbus";
        PROTON_PASS_DISABLE_TELEMETRY = 1;
      };
}
