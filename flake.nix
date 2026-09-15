# https://daiderd.com/nix-darwin/
# https://daiderd.com/nix-darwin/manual/index.html
{
  description = "Blesswin's system flake";

  inputs = {
    # Package sets
    # https://github.com/NixOS/nixos-org-configurations/blob/master/channels.nix
    nixpkgs-master = { url = "github:NixOS/nixpkgs/master"; };
    nixpkgs-stable = { url = "github:NixOS/nixpkgs/nixos-26.05"; };
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

      realmModules = realm: os:
        if realm == "personal" && os == "darwin" then [ ./commons/personal-darwin.nix ]
        else if realm == "personal" && os == "linux" then [ ./commons/personal-linux.nix ]
        else if realm == "work" && os == "darwin" then [ ./commons/work-darwin.nix ]
        else if realm == "work" && os == "linux" then [ ./commons/work-linux.nix ]
        else throw "unknown realm/os: ${realm}/${os}";

      nixosSystem = { system, extraModules ? [ ], systemConfig }: hostName:
        let
          pkgsUnstable = genPkgs system nixpkgs-unstable;
          pkgsMaster = genPkgs system nixpkgs-master;
          pkgsStable = genPkgs system nixpkgs-stable;
        in
        nixpkgs-stable.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit self pkgsUnstable pkgsMaster pkgsStable inputs systemConfig; };
          modules = [
            ./commons/commons.nix
          ] ++ realmModules systemConfig.realm "linux"
          ++ extraModules;
        };
      # Bootstrap images skip heavy commons packages; converge with do-cloud-dev after boot.
      nixosBootstrapSystem = { system, extraModules ? [ ], systemConfig }: hostName:
        let
          pkgsUnstable = genPkgs system nixpkgs-unstable;
          pkgsMaster = genPkgs system nixpkgs-master;
          pkgsStable = genPkgs system nixpkgs-stable;
        in
        nixpkgs-stable.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit self pkgsUnstable pkgsMaster pkgsStable inputs systemConfig; };
          modules = [
            ./commons/commons-bootstrap.nix
          ] ++ realmModules systemConfig.realm "linux"
          ++ extraModules;
        };
      doCloudSystemConfig = {
        username = "blesswinsamuel";
        realm = "personal";
        authorizedKeys = [
          # cat ~/.ssh/id_ed25519.pub | pbcopy
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBv5qmX429IPSo2TsFywtCr9w7kprutEYCBS1c291jZv blesswinsamuel@bless-mac-wired.home.lan"
        ];
      };
      darwinSystem = { system, extraModules ? [ ], systemConfig }: hostName:
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
            ./commons/darwin.nix
          ] ++ realmModules systemConfig.realm "darwin"
          ++ extraModules;
        };

      processConfigurations = nixpkgs-unstable.lib.mapAttrs (n: v: v n);

    in
    {
      nixosConfigurations = processConfigurations {
        hp-laptop = nixosSystem {
          system = "x86_64-linux";
          extraModules = [
            disko.nixosModules.disko
            ./commons/linux.nix
            ./commons/personal-linux-desktop.nix
            ./hosts/hp-laptop/hp-laptop-hardware-configuration.nix
            ./hosts/hp-laptop/hp-laptop-disk-config.nix
            ./hosts/hp-laptop/hp-laptop.nix
          ];
          systemConfig = {
            username = "blesswinsamuel";
            realm = "personal";
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
            ./commons/linux.nix
            ./commons/personal-linux-desktop.nix
            ./hosts/hp-chromebox/hp-chromebox-hardware-configuration.nix
            ./hosts/hp-chromebox/hp-chromebox.nix
          ];
          systemConfig = {
            username = "blesswinsamuel";
            realm = "personal";
            authorizedKeys = [
              # cat ~/.ssh/id_ed25519.pub | pbcopy
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBv5qmX429IPSo2TsFywtCr9w7kprutEYCBS1c291jZv blesswinsamuel@bless-mac-wired.home.lan"
            ];
            rootHashedPassword = "$y$j9T$Qnv1FPJ76Q2.nY6U2d/m..$JzPVeJwn9X/q9K2OjcZMVXqke/AJ7DuLmAzgKX6oQR4"; # nix run nixpkgs#mkpasswd --command 'mkpasswd xxx'
            userHashedPassword = "$y$j9T$7vegI80UKMuJ8fLOitraF/$6C1BYMnljFjsQInlBaxjP.e6n3cSBkIhOSFDv6WaCP5";
          };
        };
        do-cloud-bootstrap = nixosBootstrapSystem {
          system = "x86_64-linux";
          extraModules = [ ./hosts/do-cloud-dev/do-cloud-dev.nix ];
          systemConfig = doCloudSystemConfig;
        };
        do-cloud-dev = nixosSystem {
          system = "x86_64-linux";
          extraModules = [ ./hosts/do-cloud-dev/do-cloud-dev.nix ];
          systemConfig = doCloudSystemConfig;
        };
      };
      darwinConfigurations = processConfigurations {
        mac-studio = darwinSystem {
          system = "aarch64-darwin";
          extraModules = [ ./hosts/mac-studio/mac-studio.nix ];
          systemConfig = {
            username = "blesswinsamuel";
            realm = "personal";
          };
        };
        work-laptop = darwinSystem {
          system = "aarch64-darwin";
          extraModules = [ ./hosts/work-laptop/work-laptop.nix ];
          systemConfig = {
            username = "bsamuel";
            realm = "work";
          };
        };
      };

      # # Expose the package set, including overlays, for convenience.
      # darwinPackages = self.darwinConfigurations."mac-studio".pkgs;
    };
}

# Why no Home Manager? See README.md § Architecture.
# /Users/blesswinsamuel/.nix-profile/bin - via home-manager.home.packages option (home-manager)
# /etc/profiles/per-user/blesswinsamuel/bin - via users.users.<name>.packages option (nix-darwin)
# /run/current-system/sw/bin - via environment.systemPackages (nix-darwin)
