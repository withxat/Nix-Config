{
  description = "❄️  A single source of truth for my machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, ... }: {
    nixosConfigurations.oyama = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        disko.nixosModules.disko
        ./hosts/oyama/disko.nix
        ./hosts/oyama/configuration.nix
      ];
    };

    packages.x86_64-linux.image =
      self.nixosConfigurations.oyama.config.system.build.diskoImages;
  };
}
