{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-unstable.follows = "nixpkgs";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs =
    inputs @ { self
    , nixpkgs
    , home-manager
    , ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      unstable = pkgs;
      defaultSpecialArgs = inputs // {
        inherit inputs pkgs unstable;
        masterUser = {
          name = "lluz";
          terminal = "kitty";
          editor = "hx";
        };
        openai-codex = null;
      };
    in
    {
      homeModules = {
        lluz = ./lluz.nix;
        karolayne = ./karolayne.nix;
      };

      homeConfigurations = {
        lluz = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = defaultSpecialArgs;
          modules = [ self.homeModules.lluz ];
        };

        karolayne = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = defaultSpecialArgs;
          modules = [ self.homeModules.karolayne ];
        };
      };
    };
}
