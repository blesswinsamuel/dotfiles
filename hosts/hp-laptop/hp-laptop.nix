{ self, pkgsUnstable, pkgsStable, pkgsMaster, lib, config, secrets, systemConfig, ... }: {
  networking.hostName = "hp-laptop";
  users.users.${systemConfig.username}.packages = [
    # mongodb
    # mongosh
    # mongodb-tools
    pkgsUnstable.redis
    pkgsUnstable.postgresql_14
    pkgsUnstable.mailhog
    # grafana
    # traefik
    # victoriametrics

    # Kubernetes
    pkgsUnstable.kapp
    pkgsUnstable.kubectl
    pkgsUnstable.kubernetes-helm
    # pkgs.kopia
    pkgsUnstable.krew
    pkgsUnstable.stern
    pkgsUnstable.kubie

    # Docker
    pkgsUnstable.podman
    pkgsUnstable.podman-compose
    pkgsUnstable.podman-tui

    # Infrastructure management
    # pkgsMaster.terraform
    # nodePackages.cdk8s-cli
    # pkgsMaster.nodePackages.cdktf-cli

    # TUI
    pkgsUnstable.k9s
    pkgsUnstable.gitui

    # pkgs.yt-dlp
    # pkgs.ffmpeg
    # pkgs.imagemagick

    # Tools
    pkgsUnstable.autossh
    pkgsUnstable.direnv
    pkgsUnstable.atuin
    pkgsUnstable.just
    pkgsUnstable.neovim
    pkgsUnstable.gojq
    pkgsUnstable.hey # HTTP load generator, ApacheBench (ab) replacement
    pkgsUnstable.rclone
    pkgsUnstable.qpdf
    pkgsUnstable.pv
    pkgsUnstable.gnused
    # pkgs.gnutar
    # pkgs.gzip
    # pkgs.unzip
    pkgsUnstable.tree
    pkgsUnstable.websocat
    pkgsUnstable.xh
    # pkgsMaster.unison
    pkgsUnstable.hexyl # command line hex viewer
    # qrcp # transfer files over Wi-Fi from your computer to a mobile device by scanning a QR code without leaving the terminal
    pkgsUnstable.smartmontools # tools for monitoring the health of hard drives
    pkgsUnstable.syncthing # continuous file synchronization program
    pkgsUnstable.wakeonlan # sends magic packets to wake up network-devices
    pkgsUnstable.mkcert # simple tool for making locally-trusted development certificates
    pkgsUnstable.delta # syntax-highlighting pager for git

    # Network tools
    pkgsUnstable.nmap
    pkgsUnstable.inetutils
    pkgsUnstable.iperf
    pkgsUnstable.openconnect

    # 3rd party cloud service tools
    # pkgsMaster.awscli2
    # pkgs.bitwarden-cli
    pkgsUnstable.gh

    pkgsUnstable.teller
    pkgsUnstable.git-secrets
    pkgsUnstable.gitleaks

    # pkgs.home-assistant-cli

    pkgsUnstable.xclip

    # GUIs
    pkgsUnstable.google-chrome
    pkgsUnstable.vscode
    pkgsUnstable.telegram-desktop
    pkgsUnstable.slack
    pkgsUnstable.sublime-merge
    pkgsUnstable.sublime4
    pkgsUnstable.github-desktop
    pkgsUnstable.zed-editor
    pkgsUnstable.obsidian
    pkgsUnstable.ghostty
    pkgsUnstable.kdePackages.krdc
  ];
  fonts.packages = with pkgsUnstable; [
    # (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    # fira-code
    # droid-sans-mono
    # jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.jetbrains-mono
  ];
  programs.firefox.enable = true;
  programs.firefox.package = pkgsUnstable.firefox;
  nixpkgs.config.firefox.enablePlasmaBrowserIntegration = true;
  programs.chromium.enablePlasmaBrowserIntegration = true;
  programs._1password.enable = true;
  programs._1password.package = pkgsUnstable._1password-cli;
  programs._1password-gui.enable = true;
  programs._1password-gui.package = pkgsUnstable._1password-gui;
  # programs._1password-gui.polkitPolicyOwners = ["blesswinsamuel"];
  services.tailscale.enable = true;
  security.polkit.enable = true;
}
