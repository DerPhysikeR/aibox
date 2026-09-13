{
  description = "Disposable OpenCode agent VM";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = { self, nixpkgs, llm-agents, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.agent = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit llm-agents; };

        modules = [
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
