{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    flake-programs-sqlite = { url = "github:wamserma/flake-programs-sqlite"; inputs.nixpkgs.follows = "nixpkgs"; }; # Should allow command-not-found to work

    thorium.url = "github:Rishabh5321/custom-packages-flake";
    trid = { url = "https://mark0.net/download/trid.zip"; flake = false; };
    triddefs = { url = "http://mark0.net/download/triddefs.zip"; flake = false; };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.emerald = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./emerald.nix
        inputs.home-manager.nixosModules.default
        inputs.flake-programs-sqlite.nixosModules.programs-sqlite
      ];
    };
    nixosConfigurations.ruby = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./ruby.nix
        inputs.home-manager.nixosModules.default
        inputs.flake-programs-sqlite.nixosModules.programs-sqlite
      ];
    };
  };
}
