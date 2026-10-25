{ config, pkgs, pkgsUnstable, systemConfig, ... }:
let
  username = systemConfig.username;
  homeDir = "/home/${username}";
in
{
  # RustDesk as a third remoting path, alongside Sunshine and Guacamole.
  # Direct-IP only: no rendezvous/relay servers, so traffic stays on Tailscale.
  environment.systemPackages = [ pkgsUnstable.rustdesk ];

  # Answering incoming connections needs the daemon plus a permanent password:
  #   rustdesk --password '<secret>'
  # The daemon runs as a user service inside the graphical session so it can
  # capture the X display.
  systemd.user.services.rustdesk = {
    description = "RustDesk (direct IP over Tailscale)";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgsUnstable.rustdesk}/bin/rustdesk";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };

  # Autostart for the same reason as x11vnc/sunshine: XFCE is not a
  # systemd-aware session, so graphical-session.target never activates.
  environment.etc."xdg/autostart/rustdesk.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=RustDesk
    Exec=${pkgs.systemd}/bin/systemctl --user start rustdesk.service
    X-GNOME-Autostart-enabled=true
    NoDisplay=true
  '';

  # Seed direct-IP mode. RustDesk listens on 21118 by default; without a
  # rendezvous server it must be dialled by IP.
  environment.etc."rustdesk/RustDesk2.toml".text = ''
    rendezvous_server = '127.0.0.1'
    nat_type = 1
    serial = 0

    [options]
    relay-server = "127.0.0.1"
    api-server = ""
    allow-remote-config-modification = "Y"
    enable-audio = "Y"
  '';

  systemd.tmpfiles.rules = [
    "d ${homeDir}/.config 0755 ${username} users -"
    "d ${homeDir}/.config/rustdesk 0700 ${username} users -"
    "C ${homeDir}/.config/rustdesk/RustDesk2.toml 0600 ${username} users - /etc/rustdesk/RustDesk2.toml"
  ];

  # RustDesk's direct listener.
  networking.firewall.allowedTCPPorts = [ 21118 ];
}
