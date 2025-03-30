{ self, pkgsUnstable, lib, config, systemConfig, ... }: {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${systemConfig.username} = {
    isNormalUser = true;
    description = "Blesswin Samuel";
    hashedPassword = systemConfig.userHashedPassword;
    openssh.authorizedKeys.keys = systemConfig.authorizedKeys;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  users.users.root = {
    openssh.authorizedKeys.keys = systemConfig.authorizedKeys;
    hashedPassword = systemConfig.rootHashedPassword;
  };

  environment.systemPackages = with pkgsUnstable; [
    pciutils
    usbutils
    lm_sensors

    # KDE
    libsForQt5.kconfig
    kdePackages.plasma-browser-integration
  ];

  services.xserver.enable = true; # optional
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # services.displayManager.sddm.settings.General.DisplayServer = "wayland";

  # qt = {
  #   enable = true;
  #   platformTheme = "gnome";
  #   style = "adwaita-dark";
  # };




  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = lib.mkDefault true;
  # nmcli device wifi connect <SSID> password <password>
  # cat /etc/NetworkManager/system-connections/EL-BETHEL.nmconnection

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n = {
    # defaultLocale = "en_IN";
    defaultLocale = "en_GB.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "en_GB.UTF-8/UTF-8"
      "en_IN/UTF-8"
    ];
    extraLocaleSettings = {
      # LC_ADDRESS = "en_IN";
      # LC_IDENTIFICATION = "en_IN";
      # LC_MEASUREMENT = "en_IN";
      # LC_MONETARY = "en_IN";
      # LC_NAME = "en_IN";
      # LC_NUMERIC = "en_IN";
      # LC_PAPER = "en_IN";
      # LC_TELEPHONE = "en_IN";
      # LC_TIME = "en_IN";
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.enable = lib.mkDefault true;
  networking.firewall.allowPing = true;
  networking.nftables.enable = true;
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  # https://nixos.org/manual/nixos/unstable/release-notes
  system.stateVersion = "24.05"; # Did you read the comment?

  users.mutableUsers = false;
  services.openssh.settings.PasswordAuthentication = false;


  # https://github.com/NixOS/nixpkgs/pull/126777/files
  # https://medium.com/@ivanermilov/how-to-fix-inotify-cannot-be-used-reverting-to-polling-too-many-open-files-bb1c1437dbf
  # https://github.com/NixOS/nixpkgs/issues/36214

  # Increase the amount of inotify watchers
  # Note that inotify watches consume 1kB on 64-bit machines.
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 1048576; # default:  8192
    "fs.inotify.max_user_instances" = 8192; # default:   128
    "fs.inotify.max_queued_events" = 32768; # default: 16384
  };

  services.timesyncd.enable = true;

  services.libinput.touchpad.naturalScrolling = true;
}
