{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    nix-proton-cachyos.url = "github:Shochraos/nix-proton-cachyos";
    #nix-flatpak.url = "github:gmodena/nix-flatpak";
    flake-programs-sqlite = { url = "github:wamserma/flake-programs-sqlite"; inputs.nixpkgs.follows = "nixpkgs"; }; # Should allow command-not-found to work
    
    thorium.url = "github:Rishabh5321/custom-packages-flake";
    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
    trid = { url = "https://mark0.net/download/trid.zip"; flake = false; };
    triddefs = { url = "http://mark0.net/download/triddefs.zip"; flake = false; };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.emerald = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        inputs.home-manager.nixosModules.default
        #inputs.nix-flatpak.nixosModules.nix-flatpak
        inputs.flake-programs-sqlite.nixosModules.programs-sqlite
      ];
    };
  };
}
