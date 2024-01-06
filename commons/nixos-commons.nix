{ self, pkgs, lib, config, systemConfig, ... }: { 
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${systemConfig.username} = {
    isNormalUser = true;
    description = "Blesswin Samuel";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      #  thunderbird
    ];
  };
}
