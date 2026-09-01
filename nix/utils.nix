{ inputs, nixpkgs, home-manager }:

{
	# A host is nix/hosts/<hostname> plus the home-manager module. The
	# baseline (../modules/system) and features (desktop, gaming) are
	# picked inside the host file.
	make_host = hostname: nixpkgs.lib.nixosSystem {
		specialArgs = { inherit inputs; };
		modules = [
			./hosts/${hostname}
			home-manager.nixosModules.home-manager
			{ networking.hostName = hostname; }
		];
	};

	# Standalone home-manager for non-NixOS machines. Same entry point as
	# the NixOS-embedded home: nix/homes/<username>.
	make_home = username: home-manager.lib.homeManagerConfiguration {
		pkgs = import nixpkgs {
			system = "x86_64-linux";
			config.allowUnfree = true;
		};
		modules = [ ./homes/${username} ];
	};
}
