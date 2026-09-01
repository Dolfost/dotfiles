{
	description = "NixOS + home-manager configuration";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
		home-manager = {
			url = "github:nix-community/home-manager/release-26.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = inputs@{ self, nixpkgs, home-manager, ... }:
	let
		utils = import ./nix/utils.nix { inherit inputs nixpkgs home-manager; };
	in {
		nixosConfigurations = {
			aorus = utils.make_host "aorus";
			loq = utils.make_host "loq";
		};

		# Standalone entry points for non-NixOS machines. The GUI/gaming
		# home halves default off there (no osConfig); flip dotfiles.graphical
		# or the per-feature dotfiles.<feature>.enable in the home to opt in.
		homeConfigurations = {
			vladyslav = utils.make_home "vladyslav";
		};
	};
}
