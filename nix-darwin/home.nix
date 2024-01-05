{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "blesswinsamuel";
  home.homeDirectory = "/Users/blesswinsamuel";

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
    userEmail = "blesswinsamuel@gmail.com"; # TODO: template this - different for work

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

  # home.file = {
  #   starship = {
  #     enable = true;
  #     source = ./starship/starship.toml;
  #     target = "~/.config/starship.toml";
  #   };
  # };

  home.packages = with pkgs; [
    jq
    nixpkgs-fmt
    home-manager
    # starship

    rustup
    go
    nodejs
    python3

    poetry
    virtualenv
    pipx
    yarn

    # mongodb
    # mongosh
    # mongodb-tools
    redis
    postgresql_14

    kapp
    kubectl
    kubernetes-helm
    kopia
    krew
    k9s
    podman
    podman-compose
    podman-tui

    awscli2
    terraform
    # nodePackages.cdk8s-cli
    nodePackages.cdktf-cli

    just
    go-task
    mprocs
    yt-dlp
    bitwarden-cli
    mailhog

    bat
    ripgrep
    htop
    direnv

    neovim
    nmap
    ncdu

    vips
  ];
}
