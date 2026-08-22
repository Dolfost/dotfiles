# Nix entry point for these dotfiles. Two independent halves during the CachyOS
# -> NixOS transition:
#
#   USER SPACE (works on CachyOS today, and on NixOS/mac later):
#     home-manager switch --flake .#vladyslav@daorus
#
#   SYSTEM (only once the box is NixOS):
#     sudo nixos-rebuild switch --flake .#daorus
#
# Both read the SAME plain config dirs in this repo via `source = ./…`, so
# nothing has to be rewritten into the Nix language until you want to.
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # Later, to run your quadlets declaratively, add:
    #   quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
    in {
      # ---- SYSTEM (NixOS) --------------------------------------------------
      nixosConfigurations.daorus = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./hosts/daorus/configuration.nix ];
      };

      # ---- USER SPACE (Home Manager, standalone) ---------------------------
      homeConfigurations."vladyslav@daorus" =
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [ ./home/vladyslav.nix ];
        };
    };
}
