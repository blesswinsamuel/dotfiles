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

  age.secrets.wakatimeApiKey = {
    file = ../secrets/wakatimeApiKey.age;
    # mode = "400";
    # owner = systemConfig.username;
  };

  home.file = {
    ".hushlogin" = {
      enable = true;
      source = ./hushlogin/hushlogin;
    };
    ".wakatime.cfg" = {
      enable = true;
      source = pkgs.substituteAll { src = ./wakatime/wakatime.cfg; homeDir = config.home.homeDirectory; };
      # onChange = ''cat ~/scratch/.wakatime.cfg > ~/.wakatime.cfg'';
    };
    ".wakatimeKey.sh" = {
      enable = true;
      # https://github.com/nix-community/home-manager/issues/322#issuecomment-1856128020
      text = ''#!/bin/bash
cat ${config.age.secrets.wakatimeApiKey.path}'';
      # onChange = ''cat ~/scratch/.wakatimeKey.sh > ~/.wakatimeKey.sh && chmod +x ~/.wakatimeKey.sh'';
      executable = true;
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

    # Common Utilities
    pkgsMaster.go-task
    pkgs.jq
    pkgs.yq-go
    pkgs.tree
    pkgs.tldr
  ];
}
