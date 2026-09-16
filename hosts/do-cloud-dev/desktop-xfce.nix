{ lib, pkgs, systemConfig, ... }:
let
  username = systemConfig.username;
  homeDir = "/home/${username}";
in
{
  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  # Headless virtio default is 1024x768; prefer 1080p for remoting.
  services.xserver.resolutions = [{ x = 1920; y = 1080; }];
  services.xserver.virtualScreen = {
    x = 1920;
    y = 1080;
  };
  # Default 96 DPI makes 1080p look tiny over VNC on Retina Macs.
  services.xserver.dpi = 144;
  services.xserver.displayManager.sessionCommands = ''
    ${lib.getExe pkgs.xrandr} --output Virtual-1 --mode 1920x1080 || true
    ${pkgs.xfconf}/bin/xfconf-query -c xsettings -p /Xft/DPI -s 144 --create -t int || true
  '';
  services.displayManager.autoLogin = {
    enable = true;
    user = username;
  };
  services.displayManager.defaultSession = "xfce";

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "gtk" ];
  };

  environment.systemPackages = with pkgs; [
    x11vnc
    tigervnc
    xfce4-terminal
  ];

  environment.etc."xdg/autostart/x11vnc-do-cloud.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=x11vnc
    Exec=systemctl --user start x11vnc.service
    X-GNOME-Autostart-enabled=true
    NoDisplay=true
  '';

  systemd.tmpfiles.rules = [
    "d ${homeDir}/.vnc 0700 ${username} users -"
  ];

  # x11vnc shares the XFCE :0 session (standard VNC password; works with macOS Screen Sharing).
  systemd.user.services.x11vnc = {
    description = "x11vnc (XFCE display :0)";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = pkgs.writeShellScript "x11vnc-xfce" ''
        set -eu
        export DISPLAY="''${DISPLAY:-:0}"
        openssl=${lib.getExe pkgs.openssl}
        passfile="$HOME/.vnc/passwd"
        passplain="$HOME/.vnc/password.txt"
        mkdir -p "$HOME/.vnc"
        if [ ! -f "$passfile" ]; then
          pass="$("$openssl" rand -base64 12 | tr -dc 'A-Za-z0-9' | head -c 8)"
          umask 077
          printf '%s\n' "$pass" > "$passplain"
          printf '%s\n%s\n' "$pass" "$pass" | ${pkgs.tigervnc}/bin/vncpasswd -f > "$passfile"
          chmod 600 "$passfile" "$passplain"
        fi
        # Wait for the X display from LightDM/XFCE.
        for _ in $(seq 1 60); do
          if [ -S "/tmp/.X11-unix/X''${DISPLAY#:}" ] || [ -S "/tmp/.X11-unix/X0" ]; then
            break
          fi
          sleep 0.5
        done
        exec ${lib.getExe pkgs.x11vnc} \
          -display "$DISPLAY" \
          -rfbauth "$passfile" \
          -rfbport 5900 \
          -forever \
          -shared \
          -listen 0.0.0.0 \
          -xkb \
          -ncache 10 \
          -ncache_cr
      '';
      Restart = "on-failure";
      RestartSec = 2;
    };
  };
}
