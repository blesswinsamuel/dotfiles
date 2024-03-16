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

  home.packages = [
    # Nix
    pkgs.nixpkgs-fmt
    pkgs.home-manager
    pkgs.nixos-rebuild

    # Linux
    # libgccjit # gcc
    pkgs.coreutils-full

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

    # Utilities
    pkgs.age

    # Experimental Utilities
    pkgs.gping
    pkgs.trippy

    # Common Utilities
    pkgsMaster.go-task
    pkgs.jq
    pkgs.yq-go
    pkgs.tree
    pkgs.tldr

    # Git
    pkgs.git
    pkgs.git-lfs
    pkgs.delta
  ];
}
