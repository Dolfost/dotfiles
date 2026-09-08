# Themeless desktop apps: the terminal emulator, notes, and whatever GUI app
# has no dedicated group of its own.
{ config, lib, pkgs, ... }:

let
	link = config.lib.dotfiles.link;
in
{
	options.dotfiles.desktop.enable = lib.mkOption {
		type = lib.types.bool;
		default = config.dotfiles.graphical;
		description = "General-purpose desktop apps.";
	};

	config = lib.mkIf config.dotfiles.desktop.enable {
		home.packages = with pkgs; [
			wezterm
			obsidian
		];

		xdg.configFile."wezterm" = link "wezterm";
	};
}
