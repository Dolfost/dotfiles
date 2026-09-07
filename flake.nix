{
	description = "NixOS + home-manager configuration";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
		nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
		home-manager = {
			url = "github:nix-community/home-manager/release-26.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		sops-nix = {
			url = "github:Mic92/sops-nix";
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
		homeConfigurations = {
			vladyslav = utils.make_home "vladyslav";
		};
	};
}
