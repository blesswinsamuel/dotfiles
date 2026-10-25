{ pkgsUnstable, systemConfig, ... }: {
  networking.hostName = "hp-chromebox-g2";

  imports = [
    ./desktop-remote.nix
    ./guacamole.nix
    ./rustdesk.nix
  ];

  # Guacamole web UI. The firewall trusts tailscale0, so this port is reachable
  # over the tailnet but not on the wired LAN.
  networking.firewall.allowedTCPPorts = [ 8080 ];

  # Wired only (eno0). wlp2s0 exists but is left unconfigured.
  networking.networkmanager.enable = true;

  # 15G RAM / 8 threads and a 16G swap partition: let the kernel use them.
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.max_map_count" = 2147483642; # elasticsearch / some dev tooling
  };

  # Kaby Lake-R stability (carried over from the lab config).
  #
  # Do not remove these to lower idle temps: idle sits warm (~53-56C) because
  # max_cstate=1 blocks deep sleep states, which looks like an easy win. It is
  # not. This box has power delivery quirks and has historically struggled to
  # wake up from suspend/deep idle. Raising max_cstate risks wake hangs for a
  # few degrees, and the replaced fan handles load fine (66C held flat under a
  # full 8-thread run).
  boot.kernelParams = [ "intel_idle.max_cstate=1" "processor.max_cstate=1" ];

  users.users.${systemConfig.username}.packages = [
    # Databases
    pkgsUnstable.redis
    pkgsUnstable.postgresql
    pkgsUnstable.mailhog

    # Kubernetes
    pkgsUnstable.kubectl
    pkgsUnstable.kubernetes-helm
    pkgsUnstable.kapp
    pkgsUnstable.krew
    pkgsUnstable.stern
    pkgsUnstable.kubie
    pkgsUnstable.k9s

    # Containers
    pkgsUnstable.podman
    pkgsUnstable.podman-compose
    pkgsUnstable.podman-tui

    # Tools
    pkgsUnstable.direnv
    pkgsUnstable.atuin
    pkgsUnstable.just
    pkgsUnstable.neovim
    pkgsUnstable.gojq
    pkgsUnstable.hey
    pkgsUnstable.rclone
    pkgsUnstable.qpdf
    pkgsUnstable.pv
    pkgsUnstable.websocat
    pkgsUnstable.hexyl
    pkgsUnstable.smartmontools
    pkgsUnstable.mkcert
    pkgsUnstable.delta
    pkgsUnstable.gitui

    # Secrets
    pkgsUnstable.teller
    pkgsUnstable.git-secrets
    pkgsUnstable.gitleaks

    pkgsUnstable.xclip

    # GUIs worth having over the remote desktop
    pkgsUnstable.vscode
    pkgsUnstable.zed-editor
    pkgsUnstable.obsidian
    pkgsUnstable.telegram-desktop
  ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
}
