{ config, pkgs, pkgsMaster, pkgsStable, lib, osConfig, systemConfig, ... }: {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = systemConfig.username;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Blesswin Samuel";
    userEmail = systemConfig.git.email;

    aliases = {
      ch = "checkout";
      b = "branch";
      c = "commit";
      s = "status";
      st = "stash";
      o = "open";
      open = "!fish -c git-open";
      t = "tree";
      tree = "log --graph --decorate --pretty=oneline --abbrev-commit";
    };

    lfs = {
      enable = true;
    };

    # https://github.com/dandavison/delta
    delta = {
      enable = true;
      options = {
        navigate = true; # use n and N to move between diff sections
      };
    };

    extraConfig = {
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      commit = {
        gpgSign = true;
      };
      # [credential]
      # 	helper = osxkeychain
    };
    # includes = [
    #   { path = "~/.gitconfig.local"; }
    # ]
  };

  programs.gpg = {
    enable = true;
    settings = {
      no-tty = true;
    };
  };

  programs.fish = {
    enable = true;
    functions = {
      fish_greeting = "";
    };
    interactiveShellInit = (builtins.readFile ./fish/env_vars.fish) + "\n" + (builtins.readFile ./fish/aliases.fish) + "\n" + (builtins.readFile ./fish/config.fish);
  };

  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ./starship/starship.toml);
  };

  programs.vim = {
    enable = true;
    extraConfig = builtins.readFile ./vim/vimrc;
  };

  programs.zsh = {
    enable = true;
    initExtra = builtins.readFile ./zsh/zshrc;
  };

  programs.bash = {
    enable = true;
  };

  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ./tmux/tmux.conf;
  };

  # git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
  # home.file = {
  #   ".config/nvim".source = pkgs.fetchFromGitHub {
  #     owner = "NvChad";
  #     repo = "NvChad";
  #     # https://github.com/NvChad/NvChad
  #     rev = "c2ec317b1bbcac75b7c258759b62c65261ab5d5d";
  #     hash = "sha256-mDnW3TpTl1ez4X+VU6B8GeKJDICwjw9yAaPWAmBczeo";
  #   };
  # };

  home.file = {
    ".hushlogin" = {
      enable = true;
      source = ./hushlogin/hushlogin;
    };
  };

  home.packages = [
    # Nix
    pkgs.nixpkgs-fmt
    pkgs.home-manager
    pkgs.nixos-rebuild

    # Linux
    # libgccjit # gcc
    pkgs.coreutils-full

    # Languages
    pkgs.rustup
    pkgsMaster.go
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

    # Better tools
    pkgs.prettyping
    pkgs.bat
    pkgs.dog # DNS client like dig
    pkgs.ripgrep
    pkgs.eza
    pkgs.fd
    pkgs.fzf
    pkgs.ncdu
    pkgs.dua # Disk Usage Analyzer
    pkgs.erdtree # File-tree visualizer and disk usage analyzer that is aware of .gitignore and hidden file rules
    pkgs.htop
    pkgs.difftastic
    pkgs.duf
    pkgs.sd
    pkgs.zellij # terminal multiplexer
    pkgs.bandwhich
    pkgs.bottom

    # Tools
    pkgs.autossh
    pkgs.mprocs
    pkgs.direnv
    pkgs.atuin
    pkgs.just
    pkgsMaster.go-task
    pkgs.neovim
    pkgs.tldr
    pkgs.jq
    pkgs.gojq
    pkgs.hey # HTTP load generator, ApacheBench (ab) replacement
    pkgs.yq-go
    pkgs.rclone
    pkgs.qpdf
    pkgs.pv
    pkgs.gnused
    pkgs.gnutar
    pkgs.tree
    pkgs.websocat
    pkgs.xh
    pkgs.unison
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
  ];
}
