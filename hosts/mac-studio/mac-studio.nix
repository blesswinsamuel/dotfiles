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
      "monitorcontrol"
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

  local.dock.enable = true;
  local.dock.entries = [
    { path = "/System/Applications/Launchpad.app/"; }
    { path = "/Applications/ForkLift.app/"; }
    { path = "/System/Applications/Clock.app/"; }
    { path = "/System/Applications/Weather.app/"; }
    # { path = "/System/Applications/Mail.app/"; }
    { path = "/System/Applications/Messages.app/"; }
    { path = "/System/Applications/Contacts.app/"; }
    { path = "/System/Applications/Calendar.app/"; }
    { path = "/System/Applications/Notes.app/"; }
    { path = "/System/Applications/Stocks.app/"; }
    # { path = "/Applications/Obsidian.app/"; }
    { path = "/System/Applications/Reminders.app/"; }
    { path = "/System/Applications/Music.app/"; }
    # { path = "/Applications/Spotify.app/"; }
    { path = "/System/Applications/Podcasts.app/"; }
    # { path = "/System/Applications/TV.app/"; }
    { path = "/System/Applications/VoiceMemos.app/"; }
    { path = ""; options = "--type spacer"; }
    { path = "/Applications/Home Assistant.app/"; }
    { path = "/System/Applications/Home.app/"; }
    { path = ""; options = "--type spacer"; }
    { path = "/Applications/Slack.app/"; }
    { path = "/Applications/Numbers.app/"; }
    { path = ""; options = "--type spacer"; }
    { path = "/Applications/Bitwarden.app/"; }
    { path = "/Applications/Telegram.app/"; }
    { path = "/Applications/1Password.app/"; }
    { path = "/Applications/Arc.app/"; }
    { path = "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app/"; }
    { path = "/Applications/Google Chrome.app/"; }
    { path = "/Applications/Firefox.app/"; }
    { path = "/Applications/IINA.app/"; }
    { path = ""; options = "--type spacer"; }
    { path = "/Applications/OrbStack.app/"; }
    { path = "/Applications/Visual Studio Code.app/"; }
    { path = "/Applications/Sublime Text.app/"; }
    # { path = "/Applications/Zed.app/"; }
    # { path = "/Applications/Lapce.app/"; }
    { path = "/Applications/Sublime Merge.app/"; }
    # { path = "/Applications/Fork.app/"; }
    # { path = "/Applications/GitKraken.app/"; }
    # { path = "/Applications/GitHub Desktop.app/"; }
    { path = "/Applications/Postico 2.app/"; }
    { path = "/Applications/TablePlus.app/"; }
    # { path = "/Applications/Cyberduck.app/"; }
    # { path = "/Applications/Warp.app/"; }
    { path = "/Applications/iTerm.app/"; }
    # { path = "/Applications/IntelliJ IDEA.app/"; }
    # { path = "/Applications/Lens.app/"; }
    { path = ""; options = "--type spacer"; }
    { path = "/Applications/Color Picker.app/"; }
    { path = "/System/Applications/Utilities/Activity Monitor.app/"; }
    { path = "/System/Applications/Utilities/Console.app/"; }
    { path = "/System/Applications/App Store.app/"; }
    { path = "/System/Applications/System Settings.app/"; }
    { path = "/System/Applications/Shortcuts.app/"; }
    { path = "/System/Applications/Utilities/Audio MIDI Setup.app/"; }
    { path = "/Applications/Mac Mouse Fix.app/"; }
    { path = "/System/Applications/Utilities/Screen Sharing.app/"; }
    { path = ""; options = "--type spacer"; }
    { path = "/Applications/Final Cut Pro.app/"; }
    { path = "/Applications/GarageBand.app/"; }
    { path = "/Applications/MainStage.app/"; }
    { path = "/Applications/Logic Pro X.app/"; }
    { path = "/Applications/Pianoteq 8 STAGE/Pianoteq 8 STAGE.app"; }
    { path = "/Applications/EVO.app/"; }

    { path = "/Applications/"; section = "others"; options = "--sort datemodified --view grid --display folder"; }
    { path = "/Users/blesswinsamuel/Downloads/"; section = "others"; options = "--sort dateadded --view fan --display stack"; }
    { path = "/Volumes/BleSSD/Screenshots/"; section = "others"; options = "--sort datemodified --view grid --display stack"; }
  ];
}
