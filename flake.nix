{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    stable_nixpkgs.url = "github:nixos/nixpkgs/25.11";
    thorium.url = "github:Rishabh5321/custom-packages-flake";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    plugin-zsh-nix-shell.url = "github:chisui/zsh-nix-shell";
    plugin-zsh-nix-shell.flake = false;
    plugin-zsh-autosuggestions.url = "github:zsh-users/zsh-autosuggersions";
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
      ];
    };
  };
}
