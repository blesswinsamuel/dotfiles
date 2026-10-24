{ pkgsUnstable, systemConfig, ... }: {
  networking.hostName = "hp-450-laptop";

  imports = [
    ./desktop-remote.nix
  ];

  # Wired only (eno1); wifi left unconfigured.
  networking.networkmanager.enable = true;

  users.users.${systemConfig.username}.packages = [
    # Databases
    pkgsUnstable.redis
    pkgsUnstable.postgresql
    pkgsUnstable.mailhog

    # Kubernetes
    pkgsUnstable.kubectl
    pkgsUnstable.kubernetes-helm
    pkgsUnstable.krew
    pkgsUnstable.stern
    pkgsUnstable.kubie

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
    pkgsUnstable.hey # HTTP load generator
    pkgsUnstable.rclone
    pkgsUnstable.qpdf
    pkgsUnstable.pv
    pkgsUnstable.websocat
    pkgsUnstable.hexyl
    pkgsUnstable.smartmontools
    pkgsUnstable.wakeonlan
    pkgsUnstable.mkcert
    pkgsUnstable.delta

    # Secrets
    pkgsUnstable.teller
    pkgsUnstable.git-secrets
    pkgsUnstable.gitleaks

    pkgsUnstable.xclip

    # GUIs
    pkgsUnstable.vscode
    pkgsUnstable.zed-editor
    pkgsUnstable.ghostty
    pkgsUnstable.sublime4
    pkgsUnstable.sublime-merge
    pkgsUnstable.obsidian
    pkgsUnstable.telegram-desktop
  ];
}
