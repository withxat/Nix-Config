{
  description = "❄️  A single source of truth for my machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flag = {
      url = "git+ssh://git@github.com/withxat/Flag.git?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      flag,
      ...
    }:
    {
      nixosConfigurations.ricardo = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          flag.nixosModules.default
          ./hosts/ricardo/configuration.nix
        ];
      };
    };
}
