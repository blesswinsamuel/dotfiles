{ modulesPath, pkgs, lib, ... }:
let
  username = "blesswinsamuel";
  # Keep in sync with root flake doCloudSystemConfig.authorizedKeys
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBv5qmX429IPSo2TsFywtCr9w7kprutEYCBS1c291jZv blesswinsamuel@bless-mac-wired.home.lan"
  ];
in
{
  imports = [
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
  ];

  # Same hostname as full do-cloud-dev so later `task switch` is seamless.
  networking.hostName = "do-cloud-dev";

  users.mutableUsers = false;

  users.users.${username} = {
    isNormalUser = true;
    description = "Blesswin Samuel";
    openssh.authorizedKeys.keys = authorizedKeys;
    extraGroups = [ "wheel" ];
    shell = pkgs.bashInteractive;
    packages = with pkgs; [ git jq ];
  };

  users.users.root.openssh.authorizedKeys.keys = authorizedKeys;

  security.sudo.wheelNeedsPassword = false;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  services.tailscale.enable = true;
  networking.firewall.allowedUDPPorts = [ 41641 ];

  environment.systemPackages = with pkgs; [ vim curl git jq ];

  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Asia/Kolkata";

  system.stateVersion = "25.05";
}
