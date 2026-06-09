{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    
    thorium.url = "github:Rishabh5321/custom-packages-flake";
    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
    
    plugin-zsh-nix-shell.url = "github:chisui/zsh-nix-shell";
    plugin-zsh-nix-shell.flake = false;
    plugin-zsh-autosuggestions.url = "github:zsh-users/zsh-autosuggestions";
    plugin-zsh-autosuggestions.flake = false;
    plugin-zsh-syntax-highlighting.url = "github:zsh-users/zsh-syntax-highlighting";
    plugin-zsh-syntax-highlighting.flake = false;
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./configuration.nix
        inputs.home-manager.nixosModules.default
        inputs.nix-flatpak.nixosModules.nix-flatpak
      ];
    };
  };
}
