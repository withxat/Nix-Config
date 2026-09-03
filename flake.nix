{
  description = "❄️  A single source of truth for my machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    {
      nixpkgs,
      ...
    }:
    {
      nixosConfigurations.ricardo = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/ricardo/configuration.nix
        ];
      };
    };
}
