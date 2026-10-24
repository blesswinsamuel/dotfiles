{ lib, pkgs, pkgsUnstable, systemConfig, ... }:
let
  username = systemConfig.username;
in
{
  # Remoting over Tailscale only; wired LAN stays firewalled.
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  programs._1password.enable = true;
  programs._1password.package = pkgsUnstable._1password-cli;
  programs._1password-gui.enable = true;
  programs._1password-gui.package = pkgsUnstable._1password-gui;

  programs.firefox.enable = true;
  programs.firefox.package = pkgsUnstable.firefox;

  hardware.graphics.enable = true;

  # Sunshine/Moonlight is the low-latency path; x11vnc is the fallback.
  # The i3 has no hardware encoder, so Sunshine uses CPU encode at 1080p.
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = false;
    # Web UI is reached over Tailscale, not localhost; CSRF blocks PIN submit otherwise.
    settings.csrf_allowed_origins = "https://hp-450-laptop,https://hp-450-laptop:47990";
  };

  # Sunshine injects kbd/mouse via /dev/uinput; without this, video streams but input is a no-op.
  hardware.uinput.enable = true;

  security.rtkit.enable = true;
  security.polkit.enable = true;
  programs.dconf.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  users.users.${username}.extraGroups = [ "video" "input" "uinput" "render" ];

  environment.systemPackages = with pkgsUnstable; [
    x11vnc
    tigervnc
    google-chrome
  ];

  systemd.tmpfiles.rules = [
    "d /home/${username}/.vnc 0700 ${username} users -"
  ];

  # x11vnc shares the XFCE :0 session; standard VNC auth works with macOS Screen Sharing.
  systemd.user.services.x11vnc = {
    description = "x11vnc (XFCE display :0)";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = pkgs.writeShellScript "x11vnc-xfce" ''
        set -eu
        export DISPLAY="''${DISPLAY:-:0}"
        openssl=${lib.getExe pkgsUnstable.openssl}
        passfile="$HOME/.vnc/passwd"
        passplain="$HOME/.vnc/password.txt"
        mkdir -p "$HOME/.vnc"
        if [ ! -f "$passfile" ]; then
          pass="$("$openssl" rand -base64 12 | tr -dc 'A-Za-z0-9' | head -c 8)"
          umask 077
          printf '%s\n' "$pass" > "$passplain"
          printf '%s\n%s\n' "$pass" "$pass" | ${pkgsUnstable.tigervnc}/bin/vncpasswd -f > "$passfile"
          chmod 600 "$passfile" "$passplain"
        fi
        # Wait for the X display from LightDM/XFCE.
        for _ in $(seq 1 60); do
          if [ -S "/tmp/.X11-unix/X''${DISPLAY#:}" ] || [ -S "/tmp/.X11-unix/X0" ]; then
            break
          fi
          sleep 0.5
        done
        exec ${lib.getExe pkgsUnstable.x11vnc} \
          -display "$DISPLAY" \
          -rfbauth "$passfile" \
          -rfbport 5900 \
          -forever \
          -shared \
          -listen 0.0.0.0 \
          -xkb
      '';
      Restart = "on-failure";
      RestartSec = 2;
    };
  };
}
