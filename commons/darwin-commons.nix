{ self, pkgs, lib, config, ... }: {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    vim
    tmux
    wget
    curl
    git
    openssh
  ];

  environment.shells = [ pkgs.fish pkgs.zsh ];

  environment.systemPath = [
    # "$HOME/bin"
    # "/usr/local/sbin"
    # "/usr/local/bin"
    # "~/.local/bin"
    # "~/go/bin"
    # "/opt/homebrew/bin"
    # "~/.cargo/bin"
    # "~/.config/yarn/global/node_modules/.bin/"
    # "~/.gem/ruby/2.7.0/bin"
    # "~/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin/"
    # "~/.krew/bin"
    # "/Applications/IntelliJ\\ IDEA.app/Contents/MacOS"
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina
  programs.fish.enable = true;
  programs.fish.useBabelfish = true; # no visible change - probably not required

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

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
