{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    chaotic.url = "https://flakehub.com/f/chaotic-cx/nyx/*.tar.gz";
    #nix-flatpak.url = "github:gmodena/nix-flatpak";
    
    thorium.url = "github:Rishabh5321/custom-packages-flake";
    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
    trid = { url = "https://mark0.net/download/trid.zip"; flake = false; };
    triddefs = { url = "http://mark0.net/download/triddefs.zip"; flake = false; };
    
    plugin-zsh-nix-shell = { url = "github:chisui/zsh-nix-shell"; flake = false; };
    plugin-zsh-autosuggestions = { url = "github:zsh-users/zsh-autosuggestions"; flake = false; };
    plugin-zsh-syntax-highlighting = { url = "github:zsh-users/zsh-syntax-highlighting"; flake = false; };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        inputs.home-manager.nixosModules.default
        chaotic.nixosModules.nyx-cache
        chaotic.nixosModules.nyx-overlay
        chaotic.nixosModules.nyx-registry
        #inputs.nix-flatpak.nixosModules.nix-flatpak
      ];
    };
  };
}
