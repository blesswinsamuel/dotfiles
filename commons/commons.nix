{ self, pkgsUnstable, pkgsMaster, lib, config, systemConfig, ... }: {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  # or
  # $ nix search wget
  environment.systemPackages = with pkgsUnstable; [
    vim
    tmux
    wget
    curl
    git
    # openssh
  ];

  environment.shells = with pkgsUnstable; [
    fish
    zsh
  ];

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
      pkgsUnstable.nixpkgs-fmt # deprecated
      pkgsUnstable.nixfmt-rfc-style
      pkgsUnstable.nixos-rebuild
      pkgsUnstable.nil # nix language server

      # Linux
      # libgccjit # gcc
      pkgsUnstable.coreutils-full

      # Languages
      pkgsUnstable.rustup
      pkgsUnstable.mise
      pkgsUnstable.uv
      pkgsUnstable.go

      # Better tools
      pkgsUnstable.prettyping
      pkgsUnstable.bat
      pkgsUnstable.dog # DNS client like dig
      pkgsUnstable.ripgrep
      pkgsUnstable.eza
      pkgsUnstable.fd
      pkgsUnstable.fzf
      pkgsUnstable.ncdu
      pkgsUnstable.dua # Disk Usage Analyzer
      pkgsUnstable.erdtree # File-tree visualizer and disk usage analyzer that is aware of .gitignore and hidden file rules
      pkgsUnstable.htop
      pkgsUnstable.btop
      pkgsUnstable.difftastic
      pkgsUnstable.duf
      pkgsUnstable.sd
      pkgsUnstable.zellij # terminal multiplexer
      pkgsUnstable.bandwhich
      pkgsUnstable.bottom

      # Utilities
      pkgsUnstable.age

      # Experimental Utilities
      pkgsUnstable.gping
      pkgsUnstable.trippy

      # Common Utilities
      pkgsMaster.go-task
      pkgsUnstable.jq
      pkgsUnstable.yq-go
      pkgsUnstable.tree
      pkgsUnstable.tldr
      pkgsUnstable.mprocs
      pkgsUnstable.miniserve # quickly serve some files over http (written in rust)

      # Git
      pkgsUnstable.git
      pkgsUnstable.git-lfs
      pkgsUnstable.delta

      pkgsMaster.fish
      pkgsUnstable.zsh
      pkgsUnstable.bashInteractive
      pkgsUnstable.starship
    ];
  };
}
