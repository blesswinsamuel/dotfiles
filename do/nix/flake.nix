{
  description = "Minimal DigitalOcean NixOS bootstrap image (baked into custom image)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.bootstrap = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./bootstrap.nix ];
    };
  };
}
