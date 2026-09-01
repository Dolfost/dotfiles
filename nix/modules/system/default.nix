# Baseline every host imports. Features (./desktop, ./gaming) are picked
# per host.
{ config, pkgs, ... }:

{
	imports = [
		./boot
		./locale
		./audio
		./network
		./nix
		./input
		./user
		./kernel
	];

	environment.systemPackages = with pkgs; [
		neovim wget git tmux btop
	];

	home-manager = {
		useGlobalPkgs = true;
		useUserPackages = false;
		startAsUserService = true;
		backupFileExtension = "hm-bak";
		# One entry point per user, shared with the standalone flake
		# output. The desktop/gaming home halves gate themselves on
		# osConfig, so hosts only ever pick system features.
		users.${config.dotfiles.user}.imports =
			[ (../../homes + "/${config.dotfiles.user}") ];
	};
}
