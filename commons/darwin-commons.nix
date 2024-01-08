{ self, pkgs, lib, config, systemConfig, ... }: {
  environment.systemPath = [
    # "'/Applications/Sublime Text.app/Contents/SharedSupport/bin'"
    # "'/Applications/IntelliJ IDEA.app/Contents/MacOS'"
    # "'/Applications/Visual Studio Code.app/Contents/Resources/app/bin'"
    "$HOME/bin"
    "/opt/homebrew/bin"
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
    # "/usr/local/sbin"
    # "/usr/local/bin"
    # "~/.local/bin"
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
}
