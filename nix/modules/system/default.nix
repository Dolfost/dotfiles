# Baseline every host imports. Features (./desktop, ./gaming) are picked
# per host.
{ config, lib, pkgs, ... }:

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

	# Cross-feature contract: the desktop module that knows how to move the
	# session onto a virtual display at the client's resolution (../hyprland)
	# publishes its Sunshine prep-cmd here; consumers (../gaming's Steam Big
	# Picture) pick it up without depending on the desktop module.
	options.dotfiles.sunshine.virtualDisplayPrep = lib.mkOption {
		type = with lib.types; nullOr (attrsOf str);
		default = null;
		description = "Sunshine prep-cmd ({ do, undo }) that streams on a virtual display, if this host's desktop can.";
	};

	config = {
		environment.systemPackages = with pkgs; [
			neovim wget git tmux btop
		];

		home-manager = {
			useGlobalPkgs = true;
			useUserPackages = false;
			startAsUserService = true;
			backupFileExtension = "hm-bak";
			# One entry point per user, shared with the standalone flake output. The
			# desktop/gaming home halves gate themselves on osConfig, so hosts only
			# ever pick system features.
			users.${config.dotfiles.user}.imports =
				[ (../../homes + "/${config.dotfiles.user}") ];
		};
	};
}
