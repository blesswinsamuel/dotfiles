{ self, pkgsUnstable, pkgsStable, pkgsMaster, lib, config, secrets, systemConfig, ... }: {
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

    # pkgs.yt-dlp
    # pkgs.ffmpeg
    # pkgs.imagemagick

    # Tools
    pkgsUnstable.autossh
    pkgsUnstable.direnv
    pkgsUnstable.atuin
    pkgsUnstable.just
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
    # pkgsMaster.unison
    pkgsUnstable.hexyl # command line hex viewer
    # qrcp # transfer files over Wi-Fi from your computer to a mobile device by scanning a QR code without leaving the terminal
    pkgsUnstable.smartmontools # tools for monitoring the health of hard drives
    pkgsUnstable.syncthing # continuous file synchronization program
    pkgsUnstable.wakeonlan # sends magic packets to wake up network-devices
    pkgsUnstable.mkcert # simple tool for making locally-trusted development certificates

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

    pkgsUnstable.terraform
    pkgsUnstable.buf

    # pkgs.home-assistant-cli
  ];

  # programs.git = {
  #   enable = true;
  #   userName  = "my_git_username";
  #   userEmail = "my_git_username@gmail.com";
  # };

  homebrew = {
    taps = [
      "homebrew/bundle"
      "homebrew/services"
      "hashicorp/tap"
      "wez/wezterm"
      # "davrodpin/mole"
      # "hidetatz/tap"
      # "mongodb/brew"
      # "oven-sh/bun"
      # "pyroscope-io/brew"
      # "wader/tap"

      # "alajmo/mani"
      # "autozimu/formulas"
      # "filebrowser/tap"
      # "filosottile/musl-cross"
      # "moonrepo/tap"
      # "pulumi/tap"
      # "vmware-tanzu/carvel"
    ];
    brews = [
      "llvm" # for ebpf xdp dev
      "hashicorp/tap/terraform" # nix takes a lot of time
      # "cdktf" # nix takes a lot of time - use npm install --global cdktf-cli@latest
      "unison"
      "switchaudio-osx"
    ];

    masApps = {
      "Xcode" = 497799835;
      "The Unarchiver" = 425424353;
      "MainStage" = 634159523;
      "Keynote" = 409183694;
      "Final Cut Pro" = 424389933;
      "Home Assistant" = 1099568401;
      "TestFlight" = 899247664;
      # "Unsplash Wallpapers" = 1284863847;
      "Pages" = 409201541;
      "GarageBand" = 682658836;
      # "Telegram" = 747648890;
      "Logic Pro" = 634148309;
      "Numbers" = 409203825;
      "Stockfish" = 801463932;
      # "Bitwarden" = 1352778147;
      # "Tailscale" = 1475387142;
      "Capo" = 696977615;
      "Deliveries" = 290986013;
      "AmorphousDiskMark" = 1168254295;
      "Color Picker" = 1545870783;
    };
    casks = [
      # Browsers
      "arc"
      "firefox"
      "google-chrome"
      # "orion"
      # "microsoft-edge"
      # "vivaldi"

      # Password Managers
      "bitwarden"

      # Communication
      "slack"
      # "microsoft-teams"
      "telegram"

      # Utilities
      "istat-menus"
      "itsycal"
      "mac-mouse-fix"
      "alfred"
      "raycast"
      "iterm2"
      "ghostty"
      "betterdisplay"
      "forklift"
      "trex"
      "shottr"
      "rectangle"
      "alt-tab"
      "tailscale-app"

      ## Media
      "iina"
      "imageoptim"
      "handbrake-app"
      # "spotify"

      ## Dev Tools
      "intellij-idea"
      "sublime-text"
      "visual-studio-code"
      "visual-studio-code@insiders"
      "cursor"
      "sublime-merge"
      "fork"
      "github"
      "postico"
      "tableplus"
      "wireshark-app"
      "wezterm"
      # "fleet"
      "zed"
      "warp"
      "cyberduck"
      "gitkraken"
      "pgadmin4"
      "hex-fiend"

      # Drivers
      # "homebrew/cask-drivers/audient-evo"
      # "homebrew/cask-drivers/yamaha-usb-midi-driver"

      # Fonts
      "font-jetbrains-mono-nerd-font"
      # "font-fira-code"
      # "font-hack"
      # "font-hasklig"  # Source Code Pro with ligatures
      # "font-source-code-pro"
      # "font-inconsolata"
      # "font-noto-sans"

      "1password"
      "1password-cli"
      "arduino-ide"
      "lunar"
      "obsidian"
      "reaper"
      "sonixd"
      "syntax-highlight"
      "vlc"
      "lyricsx"
      "orbstack"
      "activitywatch"
      "balenaetcher"
      "keepingyouawake"
      "rustdesk"
      "spotify"
      # "tailscale"
      "lapce"
      "inkscape"
      "latest"
      "mimestream"
      "sigmaos"
      "utm"
      "appflowy"
      "lens"
      "signal"
      "hammerspoon"
      "logseq"
      "readdle-spark"
      # "syncthing"

      # Temp
      "blackhole-2ch"
    ];
  };
}
