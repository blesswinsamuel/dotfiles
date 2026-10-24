{ pkgsUnstable, lib, systemConfig, ... }:
# Lightweight XFCE desktop for NixOS hosts, selected via `systemConfig.desktop = "xfce"`.
# Host-specific remoting/display wiring belongs in the host dir, not here.
let
  username = systemConfig.username;
in
{
  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
    displayManager.lightdm.enable = true;
  };

  services.displayManager = {
    defaultSession = "xfce";
    autoLogin = {
      enable = true;
      user = username;
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgsUnstable.xdg-desktop-portal-gtk ];
    config.common.default = [ "gtk" ];
  };

  environment.systemPackages = with pkgsUnstable; [
    xfce4-terminal
  ];
}
