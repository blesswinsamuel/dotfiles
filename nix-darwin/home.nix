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
    };
    # includes = [
    #   { path = "~/.gitconfig.local"; }
    # ]
  };

  programs.fish = {
    enable = true;
    functions = {
      fish_greeting = builtins.readFile ./fish/functions/greeting.fish;
    };
    # interactiveShellInit = (builtins.readFile ./fish/env_vars.fish) + "\n" + (builtins.readFile ./fish/aliases.fish) + "\n" + (builtins.readFile ./fish/config.fish);
  };

  home.packages = with pkgs; [ jq ];
}
