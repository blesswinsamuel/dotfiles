{ lib, modulesPath, systemConfig, ... }:
{
  imports = [
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
  ];

  networking.hostName = "do-cloud-dev";

  users.mutableUsers = false;

  users.users.${systemConfig.username} = {
    isNormalUser = true;
    description = "Blesswin Samuel";
    hashedPassword = systemConfig.userHashedPassword;
    openssh.authorizedKeys.keys = systemConfig.authorizedKeys;
    extraGroups = [ "wheel" ];
  };

  users.users.root.openssh.authorizedKeys.keys = systemConfig.authorizedKeys;

  # Password auth still disabled for SSH; password is for local/desktop login.
  security.sudo.wheelNeedsPassword = false;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  time.timeZone = "Asia/Kolkata";

  # First NixOS install on this machine (DigitalOcean image).
  system.stateVersion = "25.05";
}
