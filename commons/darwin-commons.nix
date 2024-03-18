{ self, pkgs, lib, config, systemConfig, ... }: {
  environment.systemPath = [
    # "'/Applications/Sublime Text.app/Contents/SharedSupport/bin'"
    # "'/Applications/IntelliJ IDEA.app/Contents/MacOS'"
    # "'/Applications/Visual Studio Code.app/Contents/Resources/app/bin'"
    "$HOME/bin"
    "/opt/homebrew/bin"
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
    "$HOME/.local/bin"
    # "/usr/local/sbin"
    # "/usr/local/bin"
    # "/opt/homebrew/bin"
    # "~/.config/yarn/global/node_modules/.bin/"
    # "~/.gem/ruby/2.7.0/bin"
    # "~/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin/"
    # "~/.krew/bin"
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  users.users.${systemConfig.username} = {
    home = "/Users/${systemConfig.username}";

    packages = with pkgs; [
      # Mac tools
      duti
      pngpaste # Paste image files from clipboard to file on MacOS
      mas
      dockutil
      # skhd # Simple hotkey daemon for macOS
    ];
  };

  # # The platform the configuration will be used on.
  # nixpkgs.hostPlatform = "aarch64-darwin";

  # https://nix-community.github.io/home-manager/
  # https://nix-community.github.io/home-manager/options.xhtml
  # https://nix-community.github.io/home-manager/nixos-options.xhtml
  # https://nix-community.github.io/home-manager/nix-darwin-options.xhtml
  # https://nix-community.github.io/home-manager/release-notes.xhtml
  # https://nixos.wiki/wiki/Home_Manager
  # https://mipmip.github.io/home-manager-option-search/?query=


  # https://github.com/dustinlyons/nixos-config/blob/c8099eef3b3eedb429f5084c37aba3de5781204c/modules/darwin/home-manager.nix#L30
  # https://github.com/LnL7/nix-darwin/blob/master/modules/homebrew.nix
  homebrew = {
    # This is a module from nix-darwin
    # Homebrew is *installed* via the flake input nix-homebrew
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };
    global = {
      brewfile = true;
    };

    taps = [
    ];

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    masApps = { };
    # If an app isn't available in the Mac App Store, or the version in the App Store has
    # limitiations, e.g., Transmit, install the Homebrew Cask.
    casks = [
    ];

    # For cli packages that aren't currently available for macOS in `nixpkgs`.Packages should be
    # installed in `../home/default.nix` whenever possible.
    brews = [
    ];
  };

  # https://daiderd.com/nix-darwin/manual/index.html
  system.defaults = {
    dock = {
      autohide = false;
    };

    # https://github.com/LnL7/nix-darwin/pull/557/files
    # customize settings that not supported by nix-darwin directly
    # see the source code of https://github.com/rgcr/m-cli to get all the available options
    # or
    # https://macos-defaults.com/
    # https://github.com/yannbertrand/macos-defaults
    # https://apple.stackexchange.com/a/358609
    CustomUserPreferences = {
      "com.googlecode.iterm2" = {
        CopySelection = 0;
        # PrefsCustomFolder = "/Users/${systemConfig.username}/dotfiles/configs/iterm2";
      };
      "com.apple.AppleMultitouchTrackpad" = {
        # https://macos-defaults.com/trackpad/trackpadthreefingerdrag.html
        # https://support.apple.com/en-in/guide/mac-help/unac899/mac
        # Settings -> Accessibility -> Pointer Control -> Trackpad Options -> Dragging Style -> Three Finger Drag
        TrackpadThreeFingerDrag = 1;
        # Tap to click
        Clicking = 1;
      };
      "com.apple.menuextra.clock" = {
        IsAnalog = 1;
      };
      # "com.apple.controlcenter" = {
      #   "NSStatusItem Visible Battery" = 0;
      # };
      # "com.apple.Spotlight" = {
      #   # Hide spotlight icon
      #   "NSStatusItem Visible Item-0" = 0;
      # };
      # "com.apple.custommenu.apps" = ("NSGlobalDomain");
    };
  };
}
