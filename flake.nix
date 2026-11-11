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
		herdr.url = "github:herdrdev/herdr/v0.9.5";
		hermes-agent.url = "github:NousResearch/hermes-agent";
		# Pi ships its own flake; stable is fast-forwarded to each release by
		# upstream CI, so bumping it is just `nix flake update pi`.
		pi.url = "github:earendil-works/pi/stable";
		# The UPS dashboard and its history recorder (hosts/aorus/power), pinned
		# to a release tag like herdr; a new release is a new tag here. Until
		# the next one, the outlets-fit-rows branch (the Load card lists every
		# outlet a power station has instead of eight).
		upst = {
			url = "github:Dolfost/upst/d5e6525feeaaee7d626de22a1bbb22000aaca20b";
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
			# aarch64 container on the postmarketOS phone, see nix/hosts/tissot.
			tissot = utils.make_host "tissot";
		};
		homeConfigurations = {
			vladyslav = utils.make_home "vladyslav";
		};
	};
}
