{ self, pkgs, lib, config, secrets, systemConfig, ... }: {
  homebrew = {
    taps = [
      # "homebrew/bundle"
      # "homebrew/cask-drivers"
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
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
      "font-jetbrains-mono"
      # "fork"
      # "github"
      # "istat-menus"
      "itsycal"
      "keepingyouawake"
      "1password"
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
      "tailscale"
      "trex"
      "visual-studio-code-insiders"
      # "wezterm"
      "iina"
      "zed"
      "mac-mouse-fix"
      "google-drive"

      "licecap"
      "kap"
      "keycastr"
      "slack"
      "visual-studio-code"
      # "zoom"
      "1password-cli"
      "goland"
      "iterm2"
      "docker"
      "fly"
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

      "go"
      "python@3.10"
      "make"
      # "nvm"
      "yarn"

      "golangci-lint"

      # "stern"
      # "curl"
      # "wget"
      # "direnv"
      # "git"
      # "gh"
      # "jq"
      # "kubectl"
      # "rg"
      # "yq"
      "openssl"
      { name = "mysql-client@5.7"; link = true; }
      "mysql@5.7"
      # "s3cmd"
      "vault"
      "terraform"
      # "awscli"
      # "doctl"
      # "kcat"
      # "redis"
    ];
    # brew link --overwrite --force mysql-client@5.7
  };

  local.dock.enable = true;
  local.dock.entries = [
    { path = "/System/Applications/Launchpad.app/"; }
    { path = "/System/Applications/Clock.app/"; }
    { path = "/System/Applications/Weather.app/"; }
    { path = "/System/Applications/Messages.app/"; }
    { path = "/System/Applications/Calendar.app/"; }
    { path = "/System/Applications/Notes.app/"; }
    { path = "/System/Applications/Reminders.app/"; }
    { path = "/System/Applications/Stocks.app/"; }
    # { path = "/Applications/Spotify.app/"; }
    { path = ""; options = "--type spacer"; }
    { path = "/Applications/Slack.app/"; }
    { path = "~/Applications/Gmail.app/"; }
    { path = "/Applications/1Password.app/"; }
    { path = "/Applications/Arc.app/"; }
    { path = "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app/"; }
    { path = ""; options = "--type spacer"; }
    { path = "/Applications/Visual Studio Code.app/"; }
    { path = "/Applications/Visual Studio Code - Insiders.app/"; }
    { path = "/Applications/Sublime Text.app/"; }
    { path = "/Applications/Zed.app/"; }
    { path = "/Applications/GoLand.app/"; }
    { path = "/Applications/Sublime Merge.app/"; }
    { path = "/Applications/iTerm.app/"; }
    { path = "/Applications/Sequel Ace.app/"; }
    { path = "/Applications/Docker.app/Contents/MacOS/Docker Desktop.app/"; }
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
