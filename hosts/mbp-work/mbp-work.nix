{ self, pkgsUnstable, pkgsStable, pkgsMaster, lib, config, secrets, systemConfig, ... }: {
  users.users.${systemConfig.username}.packages = [
    # pkgsMaster.terraform
    # pkgsMaster.docker-client
    pkgsMaster.stern
    pkgsMaster.kubectl
    pkgsMaster.kubectx
    pkgsMaster.kubetail
    pkgsMaster.kubernetes-helm
    pkgsMaster.direnv
    pkgsMaster.kcat
    pkgsMaster.redis
    pkgsMaster.gnumake
    pkgsMaster.kapp
    pkgsMaster.k9s
    pkgsMaster.tilt

    pkgsMaster.graphviz

    # 3rd party cloud service tools
    pkgsMaster.awscli2
    pkgsMaster.s3cmd
    pkgsMaster.gh
    pkgsMaster.doctl

    # Network tools
    pkgsUnstable.nmap
    # pkgs.inetutils
    pkgsUnstable.iperf

    pkgsMaster.libllvm
    pkgsMaster.rsync

    # pkgs.aws-iam-authenticator
    # pkgs.code-server
    # pkgs.openvscode-server

    pkgsUnstable.darwin.apple_sdk.frameworks.Security
  ]; #++ (builtins.attrValues pkgsUnstable.darwin.apple_sdk.frameworks);

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
      "google-chrome"
      "firefox"
      "font-jetbrains-mono"
      "font-jetbrains-mono-nerd-font"
      # "fork"
      "github"
      "istat-menus"
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
      # "tailscale"
      "trex"
      "visual-studio-code@insiders"
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
      # "docker"
      "orbstack"
      "devpod"
      "fly"

      "beekeeper-studio"
      "tableplus"
      "postman"
      "wireshark"
      "insomnia"
      "fork"

      "ghostty"
      "spotify"

      "gitify"
      # "devhub"
      "trailer"
    ];
    brews = [
      "unison"
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

      # "go"
      # "python@3.10"
      "make"
      # "corepack"
      # "node@16"
      # "yarn"

      # "golangci-lint"

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

  environment.variables = {
    CTHULHU_DIR = "$HOME/dev/digitalocean/cthulhu";
    DEV_TARGET_ARCH = "arm64";
    OP_SSH_KEY_REF = "op://Private/Work SSH Key/private key";
  };
}
