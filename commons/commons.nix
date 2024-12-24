{ self, pkgs, pkgsMaster, lib, config, systemConfig, ... }: {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  # or
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    tmux
    wget
    curl
    git
    openssh
  ];

  environment.shells = [ pkgs.fish pkgs.zsh ];

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina
  programs.fish.enable = true;
  programs.fish.useBabelfish = true; # no visible change - probably not required

  users.users.${systemConfig.username} = {
    shell = "/run/current-system/sw/bin/fish";

    packages = [
      # Nix
      pkgs.nixpkgs-fmt
      pkgs.nixos-rebuild

      # Linux
      # libgccjit # gcc
      pkgs.coreutils-full

      # Languages
      pkgs.rustup
      pkgs.mise
      pkgs.uv
      pkgs.go

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
      pkgs.mprocs
      pkgs.miniserve # quickly serve some files over http (written in rust)

      # Git
      pkgs.git
      pkgs.git-lfs
      pkgs.delta

      pkgsMaster.fish
      pkgs.zsh
      pkgs.bashInteractive
      pkgs.starship
    ];
  };
}
