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

  system.defaults = {
    CustomUserPreferences = {
      "com.apple.screencapture" = {
        # Change screenshot location
        location = "~/Documents/Screenshots";
      };
    };
  };
}
