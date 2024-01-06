{ self, pkgs, lib, config, systemConfig, ... }: {
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
  };
}
