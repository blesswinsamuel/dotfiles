# Examples - https://github.com/nix-community/disko/tree/master/example
# UEFI system - systemd-boot
# sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/disko-config.nix
{ lib, ... }: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Chromebox firmware boots with a short timeout; keep the menu reachable.
  boot.loader.timeout = 5;

  disko.devices = {
    disk = {
      disk1 = {
        device = "/dev/disk/by-id/ata-Matrix_256GB_DH20230620114000";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              name = "ESP";
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            # Leave room for the swap partition at the end of the disk.
            root = {
              name = "root";
              end = "-16G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
            swap-part = {
              name = "swap";
              size = "100%";
              type = "8200"; # https://github.com/nix-community/disko/issues/391
              content = {
                type = "swap";
                resumeDevice = true;
              };
            };
          };
        };
      };
    };
  };

  # Always-on desktop-class node: never suspend or hibernate.
  services.logind.settings.Login = {
    IdleAction = "ignore";
  };

  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
  };
}
