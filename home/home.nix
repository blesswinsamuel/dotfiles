{ config, pkgs, lib, osConfig, systemConfig, ... }: {
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
    envExtra = builtins.readFile ./zsh/zshenv;
  };

  programs.bash = {
    enable = true;
    bashrcExtra = builtins.readFile ./bash/bashrc;
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

  home.packages = with pkgs; [
    # Nix
    nixpkgs-fmt
    home-manager
    nixos-rebuild

    # Linux
    # libgccjit # gcc
    coreutils-full

    # Languages
    rustup
    go
    nodejs
    python3
    deno
    bun

    poetry
    virtualenv
    pipx
    yarn

    # mongodb
    # mongosh
    # mongodb-tools
    redis
    postgresql_14
    mailhog
    # grafana
    # traefik
    # victoriametrics

    # Kubernetes
    kapp
    kubectl
    kubernetes-helm
    kopia
    krew
    stern

    # Docker
    podman
    podman-compose
    podman-tui

    # Infrastructure management
    terraform
    # nodePackages.cdk8s-cli
    nodePackages.cdktf-cli

    # TUI
    k9s
    gitui

    yt-dlp
    ffmpeg
    imagemagick
    vips

    # Better tools
    prettyping
    bat
    dog
    ripgrep
    eza
    fd
    fzf
    ncdu
    htop
    difftastic
    duf
    sd
    zellij # terminal multiplexer

    # Tools
    mprocs
    direnv
    atuin
    just
    go-task
    neovim
    tldr
    jq
    yq-go
    rclone
    qpdf
    pv
    gnused
    gnutar
    tree
    websocat
    xh
    unison
    hexyl # command line hex viewer
    # qrcp # transfer files over Wi-Fi from your computer to a mobile device by scanning a QR code without leaving the terminal
    smartmontools # tools for monitoring the health of hard drives
    syncthing # continuous file synchronization program
    wakeonlan # sends magic packets to wake up network-devices
    mkcert # simple tool for making locally-trusted development certificates
    delta # syntax-highlighting pager for git

    # Network tools
    nmap
    inetutils
    iperf
    openconnect

    # 3rd party cloud service tools
    awscli2
    bitwarden-cli
    gh
    doppler
  ];
}
