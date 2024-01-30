{ self, pkgs, lib, config, secrets, systemConfig, ... }: {
  homebrew = {
    taps = [
      # "homebrew/bundle"
      # "homebrew/cask-drivers"
      "homebrew/cask-fonts"
      # "homebrew/cask-versions"
      # "homebrew/services"
      # "wez/wezterm"
    ];
    masApps = {
      # "GarageBand" = 682658836;
      # "Keynote" = 409183694;
      # "Numbers" = 409203825;
      # "Pages" = 409201541;
    };
    casks = [
      "alfred"
      "arc"
      # "docker"
      "font-jetbrains-mono"
      # "fork"
      # "github"
      # "istat-menus"
      "iterm2"
      "itsycal"
      "keepingyouawake"
      "1password"
      "slack"
      # "lens"
      "raycast"
      "rectangle"
      # "rustdesk"
      # "sloth" # shows all open files and sockets in use by all running processes on your system
      "stats"
      "sublime-merge"
      "sublime-text"
      # "syncthing"
      # "tableplus"
      # "tailscale"
      "trex"
      "visual-studio-code"
      # "visual-studio-code-insiders"
      # "wezterm"
      "zed"
    ];
    brews = [
      # "grafana"
      # "zookeeper"
      # "kafka"
      # "kind"
      # "moreutils"
      # "plow"
      # "prometheus"
      # "socat"
      # "teleport"
      # "ttyd"
      # "watch"
      # "wrk"
      # "wader/tap/fq"
      # "sshpass"
      # "the_silver_searcher"
    ];
  };

  local.dock.enable = true;
  local.dock.entries = [
    { path = "/System/Applications/Launchpad.app/"; }
    { path = "/System/Applications/Clock.app/"; }
    { path = "/System/Applications/Weather.app/"; }
    { path = "/System/Applications/Messages.app/"; }
    { path = "/System/Applications/Calendar.app/"; }
    { path = "/System/Applications/Notes.app/"; }
    { path = "/System/Applications/Stocks.app/"; }
    { path = "/System/Applications/Reminders.app/"; }
    # { path = "/Applications/Spotify.app/"; }
    { path = ""; options = "--type spacer"; }
    { path = "/Applications/Slack.app/"; }
    { path = "/Applications/1Password.app/"; }
    { path = "/Applications/Arc.app/"; }
    { path = "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app/"; }
    { path = ""; options = "--type spacer"; }
    { path = "/Applications/Visual Studio Code.app/"; }
    { path = "/Applications/Sublime Text.app/"; }
    { path = "/Applications/Zed.app/"; }
    { path = "/Applications/Sublime Merge.app/"; }
    { path = "/Applications/iTerm.app/"; }
    { path = ""; options = "--type spacer"; }
    { path = "/System/Applications/Utilities/Activity Monitor.app/"; }
    { path = "/System/Applications/Utilities/Console.app/"; }
    { path = "/System/Applications/App Store.app/"; }
    { path = "/System/Applications/System Settings.app/"; }
    # { path = "/Applications/Mac Mouse Fix.app/"; }
    { path = "/System/Applications/Utilities/Screen Sharing.app/"; }

    { path = "/Applications/"; section = "others"; options = "--sort datemodified --view grid --display folder"; }
    { path = "~/Downloads/"; section = "others"; options = "--sort dateadded --view fan --display stack"; }
    { path = "~/Documents/Screenshots/"; section = "others"; options = "--sort datemodified --view grid --display stack"; }
  ];
  system.defaults = {
    CustomUserPreferences = {
      "com.apple.screencapture" = {
        # Change screenshot location
        location = "~/Documents/Screenshots";
      };
    };
  };
}
