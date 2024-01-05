{ self, pkgs, lib, config, ... }: {
  # programs.git = {
  #   enable = true;
  #   userName  = "my_git_username";
  #   userEmail = "my_git_username@gmail.com";
  # };


  users.users.blesswinsamuel = {
    home = "/Users/blesswinsamuel";
    shell = "/run/current-system/sw/bin/fish";
  };

  # Optionally, use home-manager.extraSpecialArgs to pass
  # arguments to home.nix
}
