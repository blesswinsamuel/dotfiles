{ config, pkgs, pkgsMaster, pkgsStable, lib, osConfig, systemConfig, ... }: {
  home.packages = [
    # Languages
    pkgs.rustup
    # pkgsMaster.go
    pkgs.nodejs
    pkgs.python3
    pkgs.deno
    pkgsMaster.bun

    pkgsStable.poetry
    pkgs.virtualenv
    pkgsStable.pipx
    pkgs.yarn
    pkgs.python311Packages.pip

    # mongodb
    # mongosh
    # mongodb-tools
    pkgs.redis
    pkgs.postgresql_14
    pkgs.mailhog
    # grafana
    # traefik
    # victoriametrics

    # Kubernetes
    pkgs.kapp
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.kopia
    pkgs.krew
    pkgs.stern

    # Docker
    pkgs.podman
    pkgs.podman-compose
    pkgs.podman-tui

    # Infrastructure management
    pkgsMaster.terraform
    # nodePackages.cdk8s-cli
    pkgsMaster.nodePackages.cdktf-cli

    # TUI
    pkgs.k9s
    pkgs.gitui

    # pkgs.yt-dlp
    # pkgs.ffmpeg
    # pkgs.imagemagick

    # Tools
    pkgs.autossh
    pkgs.mprocs
    pkgs.direnv
    pkgs.atuin
    pkgs.just
    pkgs.neovim
    pkgs.gojq
    pkgs.hey # HTTP load generator, ApacheBench (ab) replacement
    pkgs.rclone
    pkgs.qpdf
    pkgs.pv
    pkgs.gnused
    # pkgs.gnutar
    # pkgs.gzip
    # pkgs.unzip
    pkgs.tree
    pkgs.websocat
    pkgs.xh
    # pkgsMaster.unison
    pkgs.hexyl # command line hex viewer
    # qrcp # transfer files over Wi-Fi from your computer to a mobile device by scanning a QR code without leaving the terminal
    pkgs.smartmontools # tools for monitoring the health of hard drives
    pkgs.syncthing # continuous file synchronization program
    pkgs.wakeonlan # sends magic packets to wake up network-devices
    pkgs.mkcert # simple tool for making locally-trusted development certificates
    pkgs.delta # syntax-highlighting pager for git

    # Network tools
    pkgs.nmap
    pkgs.inetutils
    pkgs.iperf
    pkgs.openconnect

    # 3rd party cloud service tools
    pkgs.awscli2
    pkgs.bitwarden-cli
    pkgs.gh
    pkgs.doppler

    # pkgs.home-assistant-cli
  ];
}
