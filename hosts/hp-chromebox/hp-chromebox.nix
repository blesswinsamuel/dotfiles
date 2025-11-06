# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ self, pkgsUnstable, pkgsStable, pkgsMaster, lib, config, secrets, systemConfig, ... }: {
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "hp-chromebox"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IN";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgsStable; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
  hardware.bluetooth.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${systemConfig.username} = {
    isNormalUser = true;
    description = "Blesswin Samuel";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = [
      pkgsStable.kdePackages.kate

      # mongodb
      # mongosh
      # mongodb-tools
      pkgsUnstable.redis
      pkgsUnstable.postgresql_14
      pkgsUnstable.mailhog
      # grafana
      # traefik
      # victoriametrics

      # Kubernetes
      pkgsUnstable.kapp
      pkgsUnstable.kubectl
      pkgsUnstable.kubernetes-helm
      # pkgs.kopia
      pkgsUnstable.krew
      pkgsUnstable.stern
      pkgsUnstable.kubie

      # Docker
      pkgsUnstable.podman
      pkgsUnstable.podman-compose
      pkgsUnstable.podman-tui

      # Infrastructure management
      # pkgsMaster.terraform
      # nodePackages.cdk8s-cli
      # pkgsMaster.nodePackages.cdktf-cli

      # TUI
      pkgsUnstable.gitui

      # pkgs.yt-dlp
      # pkgs.ffmpeg
      # pkgs.imagemagick

      # Tools
      pkgsUnstable.autossh
      pkgsUnstable.direnv
      pkgsUnstable.atuin
      pkgsUnstable.just
      pkgsUnstable.neovim
      pkgsUnstable.gojq
      pkgsUnstable.hey # HTTP load generator, ApacheBench (ab) replacement
      pkgsUnstable.rclone
      pkgsUnstable.qpdf
      pkgsUnstable.pv
      pkgsUnstable.gnused
      # pkgs.gnutar
      # pkgs.gzip
      # pkgs.unzip
      pkgsUnstable.websocat
      # pkgsMaster.unison
      pkgsUnstable.hexyl # command line hex viewer
      # qrcp # transfer files over Wi-Fi from your computer to a mobile device by scanning a QR code without leaving the terminal
      pkgsUnstable.smartmontools # tools for monitoring the health of hard drives
      pkgsUnstable.syncthing # continuous file synchronization program
      pkgsUnstable.wakeonlan # sends magic packets to wake up network-devices
      pkgsUnstable.mkcert # simple tool for making locally-trusted development certificates
      pkgsUnstable.delta # syntax-highlighting pager for git

      # 3rd party cloud service tools
      # pkgsMaster.awscli2
      # pkgs.bitwarden-cli
      pkgsUnstable.gh

      pkgsUnstable.teller
      pkgsUnstable.git-secrets
      pkgsUnstable.gitleaks

      # pkgs.home-assistant-cli

      pkgsUnstable.xclip

      # GUIs
      pkgsUnstable.google-chrome
      pkgsUnstable.vscode
      pkgsUnstable.telegram-desktop
      pkgsUnstable.slack
      pkgsUnstable.sublime-merge
      pkgsUnstable.sublime4
      pkgsUnstable.github-desktop
      pkgsUnstable.zed-editor
      pkgsUnstable.obsidian
      pkgsUnstable.ghostty
      pkgsUnstable.kdePackages.krdc
    ];
  };
  programs.firefox.enable = true;
  programs.firefox.package = pkgsUnstable.firefox;
  nixpkgs.config.firefox.enablePlasmaBrowserIntegration = true;
  programs.chromium.enablePlasmaBrowserIntegration = true;
  programs._1password.enable = true;
  programs._1password.package = pkgsUnstable._1password-cli;
  programs._1password-gui.enable = true;
  programs._1password-gui.package = pkgsUnstable._1password-gui;
  # programs._1password-gui.polkitPolicyOwners = ["blesswinsamuel"];
  services.tailscale.enable = true;
  security.polkit.enable = true;
}
