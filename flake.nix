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
		lib = nixpkgs.lib;

		# nix/modules exposed to hosts as the `mods` arg, so their
		# imports read `mods.desktop` instead of
		# ../../modules/desktop.nix.
		mods = lib.mapAttrs'
			(name: _: lib.nameValuePair
				(lib.removeSuffix ".nix" name)
				(./nix/modules + "/${name}"))
			(builtins.readDir ./nix/modules);

		# Every host gets the home-manager module; the rest lives
		# in nix/hosts/<name>.
		mkHost = host: lib.nixosSystem {
			specialArgs = { inherit mods; };
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
