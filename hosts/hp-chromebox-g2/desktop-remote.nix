{ lib, pkgs, pkgsUnstable, systemConfig, ... }:
let
  username = systemConfig.username;
in
{
  # Remoting over Tailscale only; the wired LAN stays firewalled.
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  programs._1password.enable = true;
  programs._1password.package = pkgsUnstable._1password-cli;
  programs._1password-gui.enable = true;
  programs._1password-gui.package = pkgsUnstable._1password-gui;

  programs.firefox.enable = true;
  programs.firefox.package = pkgsUnstable.firefox;

  programs.chromium.enablePlasmaBrowserIntegration = true;

  # UHD 620 (Kaby Lake-R): VAAPI gives hardware H.264/HEVC encode for Sunshine,
  # which the do-cloud-dev droplet had to do on CPU.
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgsUnstable; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vpl-gpu-rt # oneVPL / QuickSync runtime
      libvdpau-va-gl
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  # No `settings` here on purpose: the module only renders sunshine.conf when
  # more than one setting is given, which also disables web UI configuration.
  # Leaving it unset keeps https://<host>:47990 usable for credentials + PIN pairing.
  services.sunshine = {
    enable = true;
    autoStart = true;
    # DRM/KMS capture needs this on Wayland; required for the KMS grab path on X11 too.
    capSysAdmin = true;
    openFirewall = false;
  };

  # Sunshine injects kbd/mouse via /dev/uinput; without this, video streams but input is a no-op.
  hardware.uinput.enable = true;

  security.rtkit.enable = true;
  security.polkit.enable = true;

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
