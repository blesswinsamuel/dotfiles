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
      pkgsUnstable.devbox
      pkgsUnstable.uv
      pkgsUnstable.go

      # Better tools
      pkgsUnstable.prettyping # Better ping
      pkgsUnstable.bat # Alternative to cat
      pkgsUnstable.ripgrep # Alternative to grep
      pkgsUnstable.fd # Alternative to find
      pkgsUnstable.fzf # Fuzzy finder
      pkgsUnstable.zoxide # smarter cd command
      pkgsUnstable.eza # modern replacement for ls
      pkgsUnstable.xh # friendly curl alternative
      pkgsUnstable.zellij # terminal multiplexer
      pkgsUnstable.dust # fast and friendly alternative to du
      pkgsUnstable.dua # disk usage analyzer and viewer
      pkgsUnstable.yazi # terminal file manager
      pkgsUnstable.hyperfine # command-line benchmarking tool
      pkgsUnstable.evil-helix # modal text editor
      pkgsUnstable.fselect # SQL-like find tool
      pkgsUnstable.ncspot # Spotify client
      pkgsUnstable.ripgrep-all # like ripgrep, but searches in PDFs, E-Books, Office files, zip files, etc.
      pkgsUnstable.tokei # count lines of code
      pkgsUnstable.wiki-tui # wikipedia reader in terminal
      pkgsUnstable.just # command runner similar to make
      pkgsUnstable.mask # command runner defined in a markdown file
      pkgsUnstable.presenterm # terminal presentation tool
      pkgsUnstable.kondo # find unused files and dependencies in your project
      pkgsUnstable.ncdu
      pkgsUnstable.erdtree # File-tree visualizer and disk usage analyzer that is aware of .gitignore and hidden file rules
      pkgsUnstable.htop
      pkgsUnstable.btop
      pkgsUnstable.difftastic
      pkgsUnstable.duf
      pkgsUnstable.sd
      pkgsUnstable.bandwhich
      pkgsUnstable.bottom

      # TUI
      pkgsUnstable.k9s
      # pkgsUnstable.gitui # terminal UI for git

      # Utilities
      pkgsUnstable.age

      # Experimental Utilities
      pkgsUnstable.gping
      pkgsUnstable.trippy

      # Common Utilities
      pkgsUnstable.go-task
      pkgsUnstable.jq
      pkgsUnstable.yq-go
      pkgsUnstable.tree
      pkgsUnstable.tldr
      pkgsUnstable.mprocs
      pkgsUnstable.miniserve # quickly serve some files over http (written in rust)
      pkgsUnstable.dprint

      # Git
      pkgsUnstable.git
      pkgsUnstable.git-lfs
      pkgsUnstable.delta # syntax-highlighting pager for git

      pkgsUnstable.fish
      pkgsUnstable.nushell
      pkgsUnstable.zsh
      pkgsUnstable.bashInteractive
      pkgsUnstable.starship
      pkgsUnstable.neovim
      pkgsUnstable.lazygit

      # Fonts
      pkgsUnstable.nerd-fonts.fira-code
      pkgsUnstable.nerd-fonts.jetbrains-mono
    ];
  };
}
