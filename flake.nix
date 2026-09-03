{
  description = "❄️  A single source of truth for my machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      ...
    }:
    {
      nixosConfigurations.ricardo = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./hosts/ricardo/disko.nix
          ./hosts/ricardo/configuration.nix
        ];
      };

      packages.x86_64-linux.image = self.nixosConfigurations.ricardo.config.system.build.diskoImages;
    };
}
