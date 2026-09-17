{ lib, pkgs, pkgsUnstable, systemConfig, ... }:
let
  username = systemConfig.username;
  homeDir = "/home/${username}";

  # Flip to "hyprland" (requires rebuild/switch).
  desktop = "xfce";
in
assert lib.assertMsg (desktop == "xfce" || desktop == "hyprland")
  "hosts/do-cloud-dev: desktop must be \"xfce\" or \"hyprland\" (got ${desktop})";
{
  imports = [
    (if desktop == "xfce" then ./desktop-xfce.nix else ./desktop-hyprland.nix)
  ];

  # Same 1Password stack as personal Linux desktops (CLI + GUI over remoting).
  programs._1password.enable = true;
  programs._1password.package = pkgsUnstable._1password-cli;
  programs._1password-gui.enable = true;
  programs._1password-gui.package = pkgsUnstable._1password-gui;

  programs.firefox.enable = true;
  programs.firefox.package = pkgsUnstable.firefox;

  hardware.graphics.enable = true;

  # Remoting only over Tailscale (DO cloud firewall already blocks public inbound).
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  services.sunshine = {
    enable = true;
    autoStart = true;
    # Wayland needs this; harmless on X11 XFCE.
    capSysAdmin = true;
    openFirewall = false;
    # Web UI over Tailscale is not localhost; CSRF blocks PIN submit otherwise.
    settings.csrf_allowed_origins = "https://do-cloud-dev,https://do-cloud-dev:47990";
  };

  # Sunshine injects kbd/mouse via /dev/uinput. Without this, Moonlight streams
  # video but input is a no-op ("Unable to create virtual keyboard/mouse").
  hardware.uinput.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  security.polkit.enable = true;
  programs.dconf.enable = true;

  users.users.${username}.extraGroups = [ "video" "input" "uinput" "render" ];

  environment.systemPackages = with pkgs; [
    rustdesk
    jq
    openssl
    pkgsUnstable.google-chrome
  ];

  environment.etc."do-cloud-dev/rustdesk/RustDesk2.toml".source =
    ./config/rustdesk/RustDesk2.toml;

  systemd.tmpfiles.rules = [
    "d ${homeDir}/.config 0755 ${username} users -"
    "d ${homeDir}/.config/rustdesk 0700 ${username} users -"
    "C ${homeDir}/.config/rustdesk/RustDesk2.toml 0600 ${username} users - /etc/do-cloud-dev/rustdesk/RustDesk2.toml"
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
}
