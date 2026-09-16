{ lib, pkgs, pkgsUnstable, systemConfig, ... }:
let
  username = systemConfig.username;
  homeDir = "/home/${username}";
  configDir = ./config;
in
{
  # Hyprland + UWSM so graphical-session.target (and Sunshine) start reliably.
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # Same 1Password stack as personal Linux desktops (CLI + GUI over remoting).
  programs._1password.enable = true;
  programs._1password.package = pkgsUnstable._1password-cli;
  programs._1password-gui.enable = true;
  programs._1password-gui.package = pkgsUnstable._1password-gui;

  hardware.graphics.enable = true;

  # Auto-login into Hyprland (headless droplet — no local console needed).
  services.greetd = {
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

  # Remoting only over Tailscale (DO cloud firewall already blocks public inbound).
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # Wayland / KMS capture
    openFirewall = false;
  };

  # Lean audio stack for Sunshine (no full desktop suite).
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    config.common.default = [ "hyprland" ];
  };

  security.polkit.enable = true;
  programs.dconf.enable = true;

  users.users.${username}.extraGroups = [ "video" "input" "render" ];

  environment.systemPackages = with pkgs; [
    quickshell
    foot
    wayvnc
    rustdesk
    jq
    wl-clipboard
    hyprland
  ];

  # System-managed session configs (symlinked into the user home).
  environment.etc = {
    "do-cloud-dev/hyprland.conf".source = configDir + "/hyprland.conf";
    "do-cloud-dev/quickshell".source = configDir + "/quickshell";
    "do-cloud-dev/rustdesk/RustDesk2.toml".source = configDir + "/rustdesk/RustDesk2.toml";
  };

  # Point Hyprland at our config; seed RustDesk direct-IP settings once.
  systemd.tmpfiles.rules = [
    "d ${homeDir}/.config 0755 ${username} users -"
    "d ${homeDir}/.config/hypr 0755 ${username} users -"
    "d ${homeDir}/.config/rustdesk 0700 ${username} users -"
    "L+ ${homeDir}/.config/hypr/hyprland.conf - - - - /etc/do-cloud-dev/hyprland.conf"
    "C ${homeDir}/.config/rustdesk/RustDesk2.toml 0600 ${username} users - /etc/do-cloud-dev/rustdesk/RustDesk2.toml"
  ];

  # wayvnc shares the Hyprland headless output (VNC fallback).
  systemd.user.services.wayvnc = {
    description = "wayvnc (Hyprland / wlroots VNC)";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = pkgs.writeShellScript "wayvnc-headless" ''
        set -eu
        hyprctl=${pkgs.hyprland}/bin/hyprctl
        jq=${lib.getExe pkgs.jq}
        # Wait briefly for HEADLESS-REMOTE from hyprland.conf exec-once.
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
          exec ${lib.getExe pkgs.wayvnc} -o "$out" 0.0.0.0 5900
        fi
        exec ${lib.getExe pkgs.wayvnc} 0.0.0.0 5900
      '';
      Restart = "on-failure";
      RestartSec = 2;
    };
  };

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
}
