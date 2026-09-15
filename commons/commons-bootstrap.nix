{ pkgsUnstable, systemConfig, ... }: {
  # Slim profile for DigitalOcean bootstrap images. Full commons lands via
  # nixos-rebuild switch to do-cloud-dev after the droplet is up.
  environment.systemPackages = with pkgsUnstable; [
    vim
    curl
    git
    jq
  ];

  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;

  users.users.${systemConfig.username} = {
    shell = "${pkgsUnstable.bashInteractive}/bin/bash";
    packages = [
      pkgsUnstable.git
      pkgsUnstable.jq
    ];
  };
}
