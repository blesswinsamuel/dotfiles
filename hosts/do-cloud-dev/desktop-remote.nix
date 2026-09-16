{ lib, pkgs, pkgsUnstable, systemConfig, ... }:
let
  username = systemConfig.username;
  homeDir = "/home/${username}";
  configDir = ./config;

  # Flip to "hyprland" for Hyprland + Quickshell + wayvnc (requires rebuild/switch).
  desktop = "xfce";

  useXfce = desktop == "xfce";
  useHyprland = desktop == "hyprland";
in
assert lib.assertMsg (useXfce || useHyprland)
  "hosts/do-cloud-dev: desktop must be \"xfce\" or \"hyprland\" (got ${desktop})";
{
  # Same 1Password stack as personal Linux desktops (CLI + GUI over remoting).
  programs._1password.enable = true;
  programs._1password.package = pkgsUnstable._1password-cli;
  programs._1password-gui.enable = true;
  programs._1password-gui.package = pkgsUnstable._1password-gui;

  hardware.graphics.enable = true;

  # Remoting only over Tailscale (DO cloud firewall already blocks public inbound).
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  services.sunshine = {
    enable = true;
    autoStart = true;
    # Wayland needs this; harmless on X11 XFCE.
    capSysAdmin = true;
    openFirewall = false;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  security.polkit.enable = true;
  programs.dconf.enable = true;

  users.users.${username}.extraGroups = [ "video" "input" "render" ];

  # Shared remoting agent + session configs kept for both desktops.
  environment.systemPackages = with pkgs; [
    rustdesk
    jq
    openssl
  ] ++ lib.optionals useXfce [
    x11vnc
    tigervnc
    xfce.xfce4-terminal
  ] ++ lib.optionals useHyprland [
    quickshell
    foot
    wayvnc
    hyprland
    wl-clipboard
  ];

  environment.etc = {
    "do-cloud-dev/rustdesk/RustDesk2.toml".source = configDir + "/rustdesk/RustDesk2.toml";
    # Kept even when XFCE is active so flipping `desktop` is one-line + switch.
    "do-cloud-dev/hyprland.conf".source = configDir + "/hyprland.conf";
    "do-cloud-dev/quickshell".source = configDir + "/quickshell";
  } // lib.optionalAttrs useXfce {
    "xdg/autostart/x11vnc-do-cloud.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=x11vnc
      Exec=systemctl --user start x11vnc.service
      X-GNOME-Autostart-enabled=true
      NoDisplay=true
    '';
  };

  systemd.tmpfiles.rules = [
    "d ${homeDir}/.config 0755 ${username} users -"
    "d ${homeDir}/.config/rustdesk 0700 ${username} users -"
    "C ${homeDir}/.config/rustdesk/RustDesk2.toml 0600 ${username} users - /etc/do-cloud-dev/rustdesk/RustDesk2.toml"
  ] ++ lib.optionals useHyprland [
    "d ${homeDir}/.config/hypr 0755 ${username} users -"
    "L+ ${homeDir}/.config/hypr/hyprland.conf - - - - /etc/do-cloud-dev/hyprland.conf"
  ] ++ lib.optionals useXfce [
    "d ${homeDir}/.vnc 0700 ${username} users -"
  ];

  # RustDesk host agent — direct Tailscale IP only (no hbbs/hbbr).
  systemd.user.services.rustdesk = {
    description = "RustDesk (direct IP over Tailscale)";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.rustdesk}";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };

  # --- XFCE (default) -------------------------------------------------------
  services.xserver.enable = useXfce;
  services.xserver.desktopManager.xfce.enable = useXfce;
  services.xserver.displayManager.lightdm.enable = useXfce;
  services.displayManager.autoLogin = lib.mkIf useXfce {
    enable = true;
    user = username;
  };
  services.displayManager.defaultSession = lib.mkIf useXfce "xfce";

  # x11vnc shares the XFCE :0 session (standard VNC password; works with macOS Screen Sharing).
  systemd.user.services.x11vnc = lib.mkIf useXfce {
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
          -localhost no \
          -listen 0.0.0.0 \
          -xkb \
          -noxdamage
      '';
      Restart = "on-failure";
      RestartSec = 2;
    };
  };

  # --- Hyprland (optional; set desktop = "hyprland") ------------------------
  programs.hyprland = lib.mkIf useHyprland {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  services.greetd = lib.mkIf useHyprland {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.getExe pkgs.tuigreet} --time --cmd '${lib.getExe pkgs.uwsm} start hyprland-uwsm.desktop'";
        user = "greeter";
      };
      initial_session = {
        command = "${lib.getExe pkgs.uwsm} start hyprland-uwsm.desktop";
        user = username;
      };
    };
  };

  # Hyprland portal only when that desktop is selected (XFCE sets gtk portal above).
  xdg.portal = lib.mkMerge [
    (lib.mkIf useXfce {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = [ "gtk" ];
    })
    (lib.mkIf useHyprland {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
      config.common.default = [ "hyprland" ];
    })
  ];

  systemd.user.services.wayvnc = lib.mkIf useHyprland {
    description = "wayvnc (Hyprland / wlroots VNC)";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = pkgs.writeShellScript "wayvnc-headless" ''
        set -eu
        hyprctl=${pkgs.hyprland}/bin/hyprctl
        jq=${lib.getExe pkgs.jq}
        openssl=${lib.getExe pkgs.openssl}
        cfg="$HOME/.config/wayvnc/config"
        mkdir -p "$HOME/.config/wayvnc"
        if [ ! -f "$cfg" ]; then
          pass="$("$openssl" rand -base64 12 | tr -dc 'A-Za-z0-9' | head -c 8)"
          umask 077
          cat > "$cfg" <<EOF
address=0.0.0.0
port=5900
enable_auth=true
password=$pass
relax_encryption=true
allow_broken_crypto=true
EOF
        fi
        for _ in $(seq 1 30); do
          if "$hyprctl" -j monitors 2>/dev/null \
            | "$jq" -e 'map(select(.name | test("HEADLESS"))) | length > 0' >/dev/null; then
            break
          fi
          sleep 0.5
        done
        out="$("$hyprctl" -j monitors \
          | "$jq" -r '[.[] | select(.name | test("HEADLESS"))][0].name // empty')"
        if [ -n "$out" ]; then
          exec ${lib.getExe pkgs.wayvnc} --config "$cfg" -o "$out"
        fi
        exec ${lib.getExe pkgs.wayvnc} --config "$cfg"
      '';
      Restart = "on-failure";
      RestartSec = 2;
    };
  };
}
