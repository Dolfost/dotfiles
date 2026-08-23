{
	description = "NixOS + home-manager configuration";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
		home-manager = {
			url = "github:nix-community/home-manager/release-26.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { self, nixpkgs, home-manager, ... }:
	let
		# Every host gets the home-manager module; the rest lives in nix/hosts/<name>.
		mkHost = host: nixpkgs.lib.nixosSystem {
			modules = [
				home-manager.nixosModules.home-manager
				./nix/hosts/${host}
			];
		};
	in {
		nixosConfigurations = {
			aorus = mkHost "aorus";
			loq = mkHost "loq";
		};
	};
}
