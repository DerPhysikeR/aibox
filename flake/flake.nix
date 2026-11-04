{
  description = "Disposable OpenCode agent VM";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, llm-agents, comin, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.agent = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit llm-agents; };

        modules = [
          comin.nixosModules.comin
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
          ./configuration.nix
          ./libvirt-image.nix
        ];
      };

      # Convenient build target.
      #
      # Depending on the nixpkgs version/image framework, the exact image
      # attribute can vary. You can always use:
      #
      #   nixos-rebuild build-image --flake .#agent
      #
      # as described below.
    };
}
