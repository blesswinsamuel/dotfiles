{ self, pkgs, lib, config, secrets, systemConfig, ... }: {
  homebrew = {
    taps = [
      # "homebrew/bundle"
      # "homebrew/cask-drivers"
      # "homebrew/cask-fonts"
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

  local.dock.enable = false;
}
