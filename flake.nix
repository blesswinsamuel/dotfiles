# https://daiderd.com/nix-darwin/
# https://daiderd.com/nix-darwin/manual/index.html
{
  description = "Blesswin's system flake";

  inputs = {
    # Package sets
    # https://github.com/NixOS/nixos-org-configurations/blob/master/channels.nix
    nixpkgs-master = { url = "github:NixOS/nixpkgs/master"; };
    nixpkgs-stable = { url = "github:NixOS/nixpkgs/nixos-25.05"; };
    # nixpkgs-darwin-stable = { url = "github:NixOS/nixpkgs/nixpkgs-23.11-darwin"; };
    nixpkgs-unstable = { url = "github:NixOS/nixpkgs/nixpkgs-unstable"; };

    # Environment/system management
    nix-darwin = { url = "github:nix-darwin/nix-darwin/master"; inputs.nixpkgs.follows = "nixpkgs-unstable"; };

    disko = { url = "github:nix-community/disko"; inputs.nixpkgs.follows = "nixpkgs-unstable"; };
    # nixpkgs-darwin = { url = "github:NixOS/nixpkgs/nixpkgs-23.11-darwin" };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs-unstable, nixpkgs-master, nixpkgs-stable, disko }:
    let
      inherit (self.lib) attrValues makeOverridable mkForce optionalAttrs singleton;

      genPkgs = system: pkgs: import pkgs {
        inherit system;
        # https://nixos.wiki/wiki/Unfree_Software
        config.allowUnfree = true;
        # config.allowBroken = true;

        # for krdc
        config.permittedInsecurePackages = [
          "openssl-1.1.1w"
        ];
      };

      nixosSystem = { system, extraModules ? [ ], systemConfig, extraHomeModules ? [ ] }: hostName:
        let
          pkgsUnstable = genPkgs system nixpkgs-unstable;
          pkgsMaster = genPkgs system nixpkgs-master;
          pkgsStable = genPkgs system nixpkgs-stable;
        in
        nixpkgs-stable.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit self pkgsUnstable pkgsMaster pkgsStable inputs systemConfig; };
          modules = [
            # disko.nixosModules.disko
            ./commons/commons.nix
            # ./commons/nixos-commons.nix
          ] ++ extraModules;
        };
      darwinSystem = { system, extraModules ? [ ], systemConfig, extraHomeModules ? [ ] }: hostName:
        let
          pkgsUnstable = genPkgs system nixpkgs-unstable;
          pkgsMaster = genPkgs system nixpkgs-master;
          pkgsStable = genPkgs system nixpkgs-stable;
        in
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit self pkgsUnstable pkgsMaster pkgsStable inputs systemConfig; };
          modules = [
            ./commons/commons.nix
            ./commons/darwin-commons.nix
          ] ++ extraModules;
        };

      processConfigurations = nixpkgs-unstable.lib.mapAttrs (n: v: v n);

    in
    {
      nixosConfigurations = processConfigurations {
        hp-laptop = nixosSystem {
          system = "x86_64-linux";
          extraModules = [
            ./hosts/hp-laptop/hp-laptop-hardware-configuration.nix
            ./hosts/hp-laptop/hp-laptop-disk-config.nix
            ./hosts/hp-laptop/hp-laptop.nix
          ];
          # extraHomeModules = [ ./hosts/mbp-work/mbp-work-home.nix ];
          systemConfig = {
            username = "blesswinsamuel";
            authorizedKeys = [
              # cat ~/.ssh/id_ed25519.pub | pbcopy
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBv5qmX429IPSo2TsFywtCr9w7kprutEYCBS1c291jZv blesswinsamuel@bless-mac-wired.home.lan"
            ];
            rootHashedPassword = "$y$j9T$Qnv1FPJ76Q2.nY6U2d/m..$JzPVeJwn9X/q9K2OjcZMVXqke/AJ7DuLmAzgKX6oQR4"; # nix run nixpkgs#mkpasswd --command 'mkpasswd xxx'
            userHashedPassword = "$y$j9T$7vegI80UKMuJ8fLOitraF/$6C1BYMnljFjsQInlBaxjP.e6n3cSBkIhOSFDv6WaCP5";
          };
        };
        hp-chromebox = nixosSystem {
          system = "x86_64-linux";
          extraModules = [
            ./hosts/hp-chromebox/hp-chromebox-hardware-configuration.nix
            ./hosts/hp-chromebox/hp-chromebox.nix
          ];
          # extraHomeModules = [ ./hosts/mbp-work/mbp-work-home.nix ];
          systemConfig = {
            username = "blesswinsamuel";
            authorizedKeys = [
              # cat ~/.ssh/id_ed25519.pub | pbcopy
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBv5qmX429IPSo2TsFywtCr9w7kprutEYCBS1c291jZv blesswinsamuel@bless-mac-wired.home.lan"
            ];
            rootHashedPassword = "$y$j9T$Qnv1FPJ76Q2.nY6U2d/m..$JzPVeJwn9X/q9K2OjcZMVXqke/AJ7DuLmAzgKX6oQR4"; # nix run nixpkgs#mkpasswd --command 'mkpasswd xxx'
            userHashedPassword = "$y$j9T$7vegI80UKMuJ8fLOitraF/$6C1BYMnljFjsQInlBaxjP.e6n3cSBkIhOSFDv6WaCP5";
          };
        };
      };
      darwinConfigurations = processConfigurations {
        Blesswins-Mac-Studio = darwinSystem {
          system = "aarch64-darwin";
          extraModules = [ ./hosts/mac-studio/mac-studio.nix ];
          # extraHomeModules = [ ./hosts/mac-studio/mac-studio-home.nix ];
          systemConfig = { username = "blesswinsamuel"; };
        };
        RQHFR2KPF2 = darwinSystem {
          system = "aarch64-darwin";
          extraModules = [ ./hosts/mbp-work/mbp-work.nix ];
          # extraHomeModules = [ ./hosts/mbp-work/mbp-work-home.nix ];
          systemConfig = { username = "bsamuel"; };
        };
      };

      # # Expose the package set, including overlays, for convenience.
      # darwinPackages = self.darwinConfigurations."Blesswins-Mac-Studio".pkgs;
    };
}

# /Users/blesswinsamuel/.nix-profile/bin - via home-manager.home.packages option (home-manager)
# /etc/profiles/per-user/blesswinsamuel/bin - via users.users.<name>.packages option (nix-darwin)
# /run/current-system/sw/bin - via environment.systemPackages (nix-darwin)
