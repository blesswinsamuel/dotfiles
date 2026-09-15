# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ self, pkgsUnstable, pkgsStable, pkgsMaster, lib, config, secrets, systemConfig, ... }: {
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "hp-chromebox";

  # Locale overrides vs commons/linux.nix defaults
  i18n.defaultLocale = "en_IN";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users.${systemConfig.username}.packages = [
    pkgsStable.kdePackages.kate

    # mongodb
    # mongosh
    # mongodb-tools
    pkgsUnstable.redis
    pkgsUnstable.postgresql
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
    pkgsUnstable.websocat
    # pkgsMaster.unison
    pkgsUnstable.hexyl # command line hex viewer
    # qrcp # transfer files over Wi-Fi from your computer to a mobile device by scanning a QR code without leaving the terminal
    pkgsUnstable.smartmontools # tools for monitoring the health of hard drives
    pkgsUnstable.syncthing # continuous file synchronization program
    pkgsUnstable.wakeonlan # sends magic packets to wake up network-devices
    pkgsUnstable.mkcert # simple tool for making locally-trusted development certificates
    pkgsUnstable.delta # syntax-highlighting pager for git

    # 3rd party cloud service tools
    # pkgsMaster.awscli2
    # pkgs.bitwarden-cli

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

    pkgsUnstable.go
  ];

  services.keyd = {
    enable = true;

    keyboards.default = {
      ids = [ "*" ];

      settings = {
        main = {
          # Cmd keys trigger the cmd layer
          leftmeta = "overload(meta_mac, leftmeta)";
          rightmeta = "overload(meta_mac, rightmeta)";
          # leftmeta = "layer(meta_mac)";
          # rightmeta = "layer(meta_mac)";

          leftalt = "layer(alt)";
          rightalt = "layer(alt)";

          # Caps Lock acts as an additional Control key when held down, Esc when tapped
          capslock = "overload(control, esc)";

          # # Mac-like line navigation
          # "C-a" = "home";
          # "C-e" = "end";
        };

        "alt" = {
          # Option based word navigation
          left = "C-left";
          right = "C-right";

          backspace = "C-backspace"; # Delete previous word
        };

        "meta_mac:C" = {
          # # Essential shortcuts
          # a = "C-a"; # Select all
          # c = "C-c"; # Copy
          # v = "C-v"; # Paste
          # x = "C-x"; # Cut
          # z = "C-z"; # Undo
          # s = "C-s"; # Save
          # f = "C-f"; # Find
          # w = "C-w"; # Close tab
          # t = "C-t"; # New tab
          # q = "C-q"; # Quit
          # p = "C-p"; # Print
          # d = "C-d"; # Cmd + d in vscode
          # slash = "C-slash"; # comment/uncomment
          space = "A-f1"; # Spotlight / Search
          # tab = "A-tab"; # Next tab

          # Switch directly to an open tab (e.g., Firefox, VS Code)
          "1" = "A-1";
          "2" = "A-2";
          "3" = "A-3";
          "4" = "A-4";
          "5" = "A-5";
          "6" = "A-6";
          "7" = "A-7";
          "8" = "A-8";
          "9" = "A-9";

          # Text navigation and selection (Mac-like)
          left = "home"; # Beginning of line
          right = "end"; # End of line

          up = "C-home"; # Top of document
          down = "C-end"; # End of document
          backspace = "C-u"; # Delete line

          # As soon as 'tab' is pressed (but not yet released), switch to the 'app_switch_state' overlay
          # Send a 'M-tab' key tap before entering 'app_switch_state'
          tab = "swapm(app_switch_state, A-tab)";


          # Meta-Backtick: Switch to the next window in the application group
          # Default binding for 'cycle-group' in GNOME
          "`" = "A-f6";
        };

        # 'app_switch_state' modifier layer; inherits from the 'Meta' modifier layer
        "app_switch_state:A" = {
          # Meta-Tab: Switch to the next application
          "tab" = "A-tab";
          "right" = "A-tab";

          # Meta-Backtick: Switch to the previous application
          "`" = "A-S-tab";
          "left" = "A-S-tab";
        };
      };
    };
  };
}
