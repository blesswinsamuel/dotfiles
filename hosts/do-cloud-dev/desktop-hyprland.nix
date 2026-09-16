{ lib, pkgs, systemConfig, ... }:
let
  username = systemConfig.username;
  homeDir = "/home/${username}";
  configDir = ./config;
in
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

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

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    config.common.default = [ "hyprland" ];
  };

  environment.systemPackages = with pkgs; [
    quickshell
    foot
    wayvnc
    hyprland
    wl-clipboard
  ];

  environment.etc = {
    "do-cloud-dev/hyprland.conf".source = configDir + "/hyprland.conf";
    "do-cloud-dev/quickshell".source = configDir + "/quickshell";
  };

  systemd.tmpfiles.rules = [
    "d ${homeDir}/.config/hypr 0755 ${username} users -"
    "L+ ${homeDir}/.config/hypr/hyprland.conf - - - - /etc/do-cloud-dev/hyprland.conf"
  ];

  # wayvnc shares the Hyprland headless output.
  # macOS Screen Sharing needs legacy DES auth (8-char password) — see wayvnc README.
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
