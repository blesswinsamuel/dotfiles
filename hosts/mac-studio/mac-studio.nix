{ self, pkgs, lib, config, secrets, systemConfig, ... }: {
  # age.secrets.personalEmail = {
  #   file = ../../secrets/personalEmail.age;
  #   # path = "../../secrets-decrypted/personalEmail";
  # };

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
      "homebrew/cask-drivers"
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
      "Notes SE" = 1610634186;
      "TestFlight" = 899247664;
      "Unsplash Wallpapers" = 1284863847;
      "Pages" = 409201541;
      "Irvue" = 1039633667;
      "GarageBand" = 682658836;
      "Telegram" = 747648890;
      "Logic Pro" = 634148309;
      "Numbers" = 409203825;
      "Stockfish" = 801463932;
    };
    casks = [
      # Browsers
      "firefox"
      "google-chrome"
      "orion"

      # Utilities
      "istat-menus"
      "itsycal"
      "mouse-fix"
      "alfred"
      "raycast"
      "iterm2"
      "monitorcontrol"
      "forklift"
      "trex"
      "shottr"
      "rectangle"

      ## Media
      "iina"
      "imageoptim"
      "handbrake"
      # "spotify"

      ## Dev Tools
      "intellij-idea"
      "sublime-text"
      "visual-studio-code"
      "github"
      "sublime-merge"
      "postico"
      "tableplus"

      # Drivers
      "audient-evo" # homebrew/cask-drivers
      "yamaha-usb-midi-driver" # homebrew/cask-drivers

      # Fonts
      # "font-fira-code"
      # "font-hack"
      # "font-hasklig"  # Source Code Pro with ligatures
      # "font-source-code-pro"
      # "font-inconsolata"
      # "font-noto-sans"

      "1password"
      "arduino-ide"
      "font-jetbrains-mono-nerd-font"
      "lunar"
      "obsidian"
      "reaper"
      "sonixd"
      "syntax-highlight"
      "vlc"
      "1password-cli"
      "fork"
      "hex-fiend"
      "lyricsx"
      "orbstack"
      "sourcetree"
      "warp"
      "activitywatch"
      "balenaetcher"
      "keepingyouawake"
      "microsoft-edge"
      "rustdesk"
      "spotify"
      "tailscale"
      "wezterm"
      "cider"
      "lapce"
      "microsoft-teams"
      "pgadmin4"
      "alt-tab"
      "cyberduck"
      "gitkraken"
      "inkscape"
      "latest"
      "mimestream"
      "sigmaos"
      "utm"
      "zed"
      "appflowy"
      "lens"
      "signal"
      "swiftdefaultappsprefpane"
      "arc"
      "fleet"
      "hammerspoon"
      "logseq"
      "readdle-spark"
      "slack"
      "syncthing"
      "vivaldi"
    ];
    brews = [
      "switchaudio-osx"
    ];
  };
}
