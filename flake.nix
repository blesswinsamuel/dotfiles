# https://daiderd.com/nix-darwin/
# https://daiderd.com/nix-darwin/manual/index.html
{
  description = "Blesswin's system flake";

  inputs = {
    # Package sets
    # https://github.com/NixOS/nixos-org-configurations/blob/master/channels.nix
    nixpkgs-master = { url = "github:NixOS/nixpkgs/master"; };
    nixpkgs-stable = { url = "github:NixOS/nixpkgs/nixos-23.11"; };
    # nixpkgs-darwin-stable = { url = "github:NixOS/nixpkgs/nixpkgs-23.11-darwin"; };
    nixpkgs-unstable = { url = "github:NixOS/nixpkgs/nixpkgs-unstable"; };

    # Environment/system management
    nix-darwin = { url = "github:LnL7/nix-darwin"; inputs.nixpkgs.follows = "nixpkgs-unstable"; };
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs-unstable"; };

    agenix = { url = "github:ryantm/agenix"; };
    # nixpkgs-darwin = { url = "github:NixOS/nixpkgs/nixpkgs-23.11-darwin" };
  };

  outputs = inputs@{ self, agenix, nix-darwin, home-manager, nixpkgs-unstable, nixpkgs-master, nixpkgs-stable }:
    let
      inherit (self.lib) attrValues makeOverridable mkForce optionalAttrs singleton;

      systemConfig = builtins.fromJSON (builtins.readFile "${self}/config.json");

      genPkgs = system: pkgs: import pkgs {
        inherit system;
        # https://nixos.wiki/wiki/Unfree_Software
        config.allowUnfree = true;
      };

      nixosSystem = { system, extraModules, systemConfig, extraHmImports }: hostName:
        let
          pkgs = genPkgs system nixpkgs-unstable;
          pkgsMaster = genPkgs system nixpkgs-master;
          pkgsStable = genPkgs system nixpkgs-stable;
        in
        nixpkgs-unstable.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit self pkgs pkgsMaster pkgsStable inputs systemConfig; };
          modules = [
            home-manager.nixosModules.home-manager
            agenix.nixosModules.default
            {
              # networking.hostName = hostName;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit systemConfig pkgsMaster pkgsStable; };
              home-manager.users.${systemConfig.username} = inputs: {
                imports = [ ./home/home.nix ./home/nixos-home.nix ] ++ extraHmImports;
              };
            }
            ./commons/commons.nix
            ./commons/nixos-commons.nix
          ] ++ extraModules;
        };
      darwinSystem = { system, extraModules, systemConfig, extraHmImports }: hostName:
        let
          pkgs = genPkgs system nixpkgs-unstable;
          pkgsMaster = genPkgs system nixpkgs-master;
          pkgsStable = genPkgs system nixpkgs-stable;
        in
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit self pkgs pkgsMaster pkgsStable inputs systemConfig; };
          modules = [
            home-manager.darwinModules.home-manager
            agenix.nixosModules.default
            {
              # networking.hostName = hostName;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit systemConfig pkgsMaster pkgsStable; };
              home-manager.users.${systemConfig.username} = inputs: {
                imports = [ ./home/home.nix ./home/darwin-home.nix ] ++ extraHmImports;
              };
            }
            ./commons/commons.nix
            ./commons/darwin-commons.nix
          ] ++ extraModules;
        };

      processConfigurations = nixpkgs-unstable.lib.mapAttrs (n: v: v n);

    in
    {
      nixosConfigurations = processConfigurations {
        hp-chromebox = nixosSystem {
          system = "x86_64-linux";
          extraModules = [ ./hosts/hp-chromebox/hp-chromebox.nix ];
          extraHmImports = [ ];
          systemConfig = systemConfig.personal;
        };
      };
      darwinConfigurations = processConfigurations {
        Blesswins-Mac-Studio = darwinSystem {
          system = "aarch64-darwin";
          extraModules = [ ./hosts/mac-studio/mac-studio.nix ];
          extraHmImports = [ ./hosts/mac-studio/mac-studio-home.nix ];
          systemConfig = systemConfig.personal;
        };
        ABLSAMUE-M-28DY = darwinSystem {
          system = "x86_64-darwin";
          extraModules = [ ./hosts/mbp-work/mbp-work.nix ];
          extraHmImports = [ ./hosts/mbp-work/mbp-work-home.nix ];
          systemConfig = systemConfig.work;
        };
      };

      # # Expose the package set, including overlays, for convenience.
      # darwinPackages = self.darwinConfigurations."Blesswins-Mac-Studio".pkgs;
    };
}

# /Users/blesswinsamuel/.nix-profile/bin - via home-manager.home.packages option (home-manager)
# /etc/profiles/per-user/blesswinsamuel/bin - via users.users.<name>.packages option (nix-darwin)
# /run/current-system/sw/bin - via environment.systemPackages (nix-darwin)
