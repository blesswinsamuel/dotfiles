{ lib, pkgs, pkgsUnstable, systemConfig, ... }:
let
  username = systemConfig.username;
in
{
  # Remoting is reachable over Tailscale (trusted below) and, until Tailscale is
  # joined, over the wired LAN. Only the remoting ports are opened, not the
  # whole interface.
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.allowedTCPPorts = [
    5900 # x11vnc
  ];

  # firefox, 1Password and polkit come from commons/personal-linux-desktop.nix.

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
    # DRM/KMS capture needs this; also required for the KMS grab path on X11.
    capSysAdmin = true;
    # Publish the Sunshine ports; the web UI on 47990 must be reachable to set
    # credentials and pair a Moonlight client.
    openFirewall = true;
  };

  # Sunshine injects kbd/mouse via /dev/uinput; without this, video streams but input is a no-op.
  # (The module sets this too, but keep it explicit for the x11vnc/sunshine pair.)
  hardware.uinput.enable = true;

  users.users.${username}.extraGroups = [ "video" "input" "uinput" "render" ];

  # XFCE is not a "systemd-aware" session: NixOS only activates
  # graphical-session.target for KDE/GNOME/Hyprland/niri or XDG_CURRENT_DESKTOP
  # containing X-NIXOS-SYSTEMD-AWARE (see the nixos xsession wrapper). Anything
  # wantedBy that target therefore never starts under XFCE, so start the units
  # from the XDG autostart dir instead.
  environment.etc."xdg/autostart/x11vnc.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=x11vnc
    Exec=${pkgs.systemd}/bin/systemctl --user start x11vnc.service
    X-GNOME-Autostart-enabled=true
    NoDisplay=true
  '';

  environment.etc."xdg/autostart/sunshine.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Sunshine
    Exec=${pkgs.systemd}/bin/systemctl --user start sunshine.service
    X-GNOME-Autostart-enabled=true
    NoDisplay=true
  '';

  # X11 selections are owned by whichever app holds them and vanish when it
  # closes, which breaks copy/paste over VNC. autocutsel keeps CLIPBOARD in
  # sync with the PRIMARY selection and holds ownership itself.
  environment.etc."xdg/autostart/autocutsel.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=autocutsel
    Exec=${lib.getExe pkgsUnstable.autocutsel} -selection CLIPBOARD
    X-GNOME-Autostart-enabled=true
    NoDisplay=true
  '';

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
