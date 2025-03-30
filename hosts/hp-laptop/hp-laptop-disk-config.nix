# Examples - https://github.com/nix-community/disko/tree/master/example
# https://github.com/nix-community/disko/blob/master/example/simple-efi.nix
# https://github.com/nix-community/disko/blob/master/example/swap.nix
# BIOS system - GRUB bootloader
# UEFI systems - systemd-boot (recommended) or GRUB bootloader
# sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/disko-config.nix
{ lib, ... }: {
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.grub = {
  #   # no need to set devices, disko will add all devices that have a EF02 partition to the list already
  #   # devices = [ ];
  #   enable = true;
  #   efiSupport = true;
  #   efiInstallAsRemovable = true;
  # };

  disko.devices = {
    disk = {
      disk1 = {
        device = "/dev/disk/by-id/ata-WDC_WDS240G2G0A-00JH30_193748804521";
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
            root = {
              name = "root";
              # size = "100%";
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
                resumeDevice = true; # resume from hiberation from this device
              };
            };
          };
        };
      };
    };
  };

  # External USB drive formatting:
  # lsblk -f
  # sudo mkfs -t ext4 /dev/sdXX
  # mkdir /mnt/SSD
  # sudo mount -t auto /dev/sdXX /mnt/SSD
  # cp -r /var/lib/rancher/k3s/storage /mnt/SSD/k3s-storage

  # # USB EVM in cablet SSD
  # fileSystems."/mnt/SSD" = {
  #   device = "/dev/disk/by-id/ata-EVM_SSD_AA000000000000001359";
  #   fsType = "ext4";
  #   # options = [ "nofail" ];
  # };
}
