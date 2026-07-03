{ self, pkgsUnstable, lib, config, systemConfig, ... }: {
  homebrew.enable = false;

  environment.systemPath = [
    # "'/Applications/Sublime Text.app/Contents/SharedSupport/bin'"
    # "'/Applications/IntelliJ IDEA.app/Contents/MacOS'"
    # "'/Applications/Visual Studio Code.app/Contents/Resources/app/bin'"
    "/opt/homebrew/opt/llvm/bin"
    "$HOME/bin"
    "/opt/homebrew/bin"
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
    "$HOME/.local/bin"
    # "/usr/local/sbin"
    # "/usr/local/bin"
    # "/opt/homebrew/bin"
    # "$HOME/.config/yarn/global/node_modules/.bin/"
    # "~/.gem/ruby/2.7.0/bin"
    # "~/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin/"
    # "~/.krew/bin"
  ];
  # brew - /usr/local/sbin /usr/local/bin
  # pipx - ~/.local/bin
  # go   - ~/go/bin
  # set -gx PATH $PATH "$(brew --prefix)/opt/python/libexec/bin" # unversioned python binaries

  # # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  # nix.package = pkgsUnstable.nix;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  system.primaryUser = systemConfig.username;

  users.users.${systemConfig.username} = {
    home = "/Users/${systemConfig.username}";

    packages = with pkgsUnstable; [
      # Mac tools
      duti
      pngpaste # Paste image files from clipboard to file on MacOS
      mas
      # dockutil # Error: Package ‘swift-wrapper-5.8’ in /nix/store/038zs5b21569pjv6v0dwhi6fd95jbzvx-source/pkgs/development/compilers/swift/compiler/default.nix:700 is marked as broken, refusing to evaluate.
      # skhd # Simple hotkey daemon for macOS

      mise
    ];
  };

  # # The platform the configuration will be used on.
  # nixpkgs.hostPlatform = "aarch64-darwin";

}
