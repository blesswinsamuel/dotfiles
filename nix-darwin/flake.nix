# https://daiderd.com/nix-darwin/
# https://daiderd.com/nix-darwin/manual/index.html
{
  description = "Blesswin's system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, home-manager, nixpkgs }:
    let
      configuration = { pkgs, ... }: {
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages = with pkgs; [
          vim
          nixpkgs-fmt
          home-manager
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

        # programs.git = {
        #   enable = true;
        #   userName  = "my_git_username";
        #   userEmail = "my_git_username@gmail.com";
        # };

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 4;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";
      };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Blesswins-Mac-Studio
      darwinConfigurations."Blesswins-Mac-Studio" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            # https://nix-community.github.io/home-manager/
            # https://nix-community.github.io/home-manager/options.xhtml
            # https://nix-community.github.io/home-manager/nixos-options.xhtml
            # https://nix-community.github.io/home-manager/nix-darwin-options.xhtml
            # https://nix-community.github.io/home-manager/release-notes.xhtml
            # https://nixos.wiki/wiki/Home_Manager
            # https://mipmip.github.io/home-manager-option-search/?query=
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            users.users.blesswinsamuel.home = "/Users/blesswinsamuel";
            users.users.blesswinsamuel.shell = "/run/current-system/sw/bin/fish";
            home-manager.users.blesswinsamuel = import ./home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."Blesswins-Mac-Studio".pkgs;
    };
}
