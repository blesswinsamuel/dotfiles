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

  # The XFCE desktop-manager module already enables the portal and provides
  # xdg-desktop-portal-gtk in extraPortals. Adding it again duplicates the
  # package and breaks the user-units build with a symlink collision.
  xdg.portal.config.common.default = [ "gtk" ];

  environment.systemPackages = with pkgsUnstable; [
    xfce4-terminal
  ];
}
