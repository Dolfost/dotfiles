# Fonts the GUI features render with (waybar, wezterm, dunst, fuzzel).
{ config, lib, pkgs, ... }:

{
	options.dotfiles.fonts.enable = lib.mkOption {
		type = lib.types.bool;
		default = config.dotfiles.graphical;
		description = "Fonts for the GUI app groups.";
	};

	config = lib.mkIf config.dotfiles.fonts.enable {
		home.packages = [ pkgs.nerd-fonts.iosevka ];

		# Wires profile fonts into the user fontconfig - on NixOS and bare distros
		# alike.
		fonts.fontconfig.enable = true;
	};
}
