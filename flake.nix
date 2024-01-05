# https://daiderd.com/nix-darwin/
# https://daiderd.com/nix-darwin/manual/index.html
{
  description = "Blesswin's system flake";

  inputs = {
    agenix.url = "github:ryantm/agenix";

    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-23.11-darwin";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, agenix, nix-darwin, nixpkgs-darwin, home-manager, nixpkgs }:
    let
      systemConfig = builtins.fromJSON (builtins.readFile "${self}/config.json");

      genPkgs = system: import nixpkgs {
        inherit system;
        # https://nixos.wiki/wiki/Unfree_Software
        # config.allowUnfree = true;
        config.allowUnfreePredicate = pkg:
          builtins.elem (nixpkgs.lib.getName pkg) [
            # Add additional package names here
            "terraform"
          ];
      };

      hmConfig = import ./home/home.nix;

      # nixosSystem = system: extraModules: hostName:
      #   let
      #     pkgs = genPkgs system;
      #   in
      #   nixpkgs.lib.nixosSystem
      #     rec {
      #       inherit system;
      #       specialArgs = { inherit lib inputs; };
      #       modules = [
      #         ({ config, ... }: lib.mkMerge [{
      #           nixpkgs.pkgs = pkgs;
      #           nixpkgs.overlays = overlays;
      #           networking.hostName = hostName;
      #           system.configurationRevision = rev;
      #           home-manager.useGlobalPkgs = true;
      #           home-manager.useUserPackages = true;
      #           home-manager.extraSpecialArgs = { inherit inputs; };
      #         }

      #           (lib.mkIf config.blesswinsamuel.user.enable {
      #             # import hm stuff if enabled
      #             home-manager.users.blesswinsamuel = hmConfig;
      #           })])
      #         ./nixos-common.nix
      #       ] ++ (lib.my.mapModulesRec' (toString ./nixos-modules) import) ++ extraModules;
      #     };
      darwinSystem = { system, extraModules, systemConfig }: hostName:
        let
          pkgs = genPkgs system;
        in
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit pkgs inputs self systemConfig; };
          modules = [
            home-manager.darwinModules.home-manager
            agenix.nixosModules.default
            {
              # networking.hostName = hostName;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit systemConfig; };
              home-manager.users.blesswinsamuel = hmConfig;
            }
            ./commons/darwin-commons.nix
          ] ++ extraModules;
        };

      processConfigurations = nixpkgs.lib.mapAttrs (n: v: v n);

    in
    {
      darwinConfigurations = processConfigurations {
        Blesswins-Mac-Studio = darwinSystem {
          system = "aarch64-darwin";
          extraModules = [ ./hosts/mac-studio/mac-studio.nix ];
          systemConfig = systemConfig.personal;
        };
        ABLSAMUE-M-28DY = darwinSystem {
          system = "x86_64-darwin";
          extraModules = [ ./hosts/mbp-work/mbp-work.nix ];
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
