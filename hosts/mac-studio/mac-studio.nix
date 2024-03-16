{ self, pkgs, lib, config, secrets, systemConfig, ... }: {
  # programs.git = {
  #   enable = true;
  #   userName  = "my_git_username";
  #   userEmail = "my_git_username@gmail.com";
  # };



  # Optionally, use home-manager.extraSpecialArgs to pass
  # arguments to home.nix

  homebrew = {
    taps = [
      "homebrew/bundle"
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
      "homebrew/services"
      "wez/wezterm"
      # "davrodpin/mole"
      # "hidetatz/tap"
      # "mongodb/brew"
      # "oven-sh/bun"
      # "pyroscope-io/brew"
      # "wader/tap"

      # "alajmo/mani"
      # "autozimu/formulas"
      # "dopplerhq/cli"
      # "filebrowser/tap"
      # "filosottile/musl-cross"
      # "moonrepo/tap"
      # "pulumi/tap"
      # "vmware-tanzu/carvel"
    ];
    masApps = {
      "Xcode" = 497799835;
      "The Unarchiver" = 425424353;
      "MainStage" = 634159523;
      "Keynote" = 409183694;
      "Final Cut Pro" = 424389933;
      "Home Assistant" = 1099568401;
      "TestFlight" = 899247664;
      # "Unsplash Wallpapers" = 1284863847;
      "Pages" = 409201541;
      "GarageBand" = 682658836;
      # "Telegram" = 747648890;
      "Logic Pro" = 634148309;
      "Numbers" = 409203825;
      "Stockfish" = 801463932;
      # "Bitwarden" = 1352778147;
      # "Tailscale" = 1475387142;
      "Capo" = 696977615;
      "Deliveries" = 290986013;
      "AmorphousDiskMark" = 1168254295;
      "Color Picker" = 1545870783;
    };
    casks = [
      # Browsers
      "arc"
      "firefox"
      "google-chrome"
      # "orion"
      # "microsoft-edge"
      # "vivaldi"

      # Password Managers
      "bitwarden"

      # Communication
      "slack"
      # "microsoft-teams"
      "telegram"

      # Utilities
      "istat-menus"
      "itsycal"
      "mac-mouse-fix"
      "alfred"
      "raycast"
      "iterm2"
      "betterdisplay"
      "forklift"
      "trex"
      "shottr"
      "rectangle"
      "alt-tab"
      "swiftdefaultappsprefpane"
      "tailscale"

      ## Media
      "iina"
      "imageoptim"
      "handbrake"
      # "spotify"

      ## Dev Tools
      "intellij-idea"
      "sublime-text"
      "visual-studio-code"
      "sublime-merge"
      "fork"
      "github"
      "postico"
      "tableplus"
      "wireshark"
      "wezterm"
      # "fleet"
      "zed"
      "warp"
      "cyberduck"
      "gitkraken"
      "pgadmin4"
      "hex-fiend"

      # Drivers
      # "homebrew/cask-drivers/audient-evo"
      # "homebrew/cask-drivers/yamaha-usb-midi-driver"

      # Fonts
      "font-jetbrains-mono-nerd-font"
      # "font-fira-code"
      # "font-hack"
      # "font-hasklig"  # Source Code Pro with ligatures
      # "font-source-code-pro"
      # "font-inconsolata"
      # "font-noto-sans"

      "1password"
      "1password-cli"
      "arduino-ide"
      "lunar"
      "obsidian"
      "reaper"
      "sonixd"
      "syntax-highlight"
      "vlc"
      "lyricsx"
      "orbstack"
      "activitywatch"
      "balenaetcher"
      "keepingyouawake"
      "rustdesk"
      "spotify"
      # "tailscale"
      "lapce"
      "inkscape"
      "latest"
      "mimestream"
      "sigmaos"
      "utm"
      "appflowy"
      "lens"
      "signal"
      "hammerspoon"
      "logseq"
      "readdle-spark"
      "syncthing"
    ];
    brews = [
      "go"
      "unison"
      "switchaudio-osx"
    ];
  };
}
