# The terminal emulator.
{ config, lib, pkgs, ... }:

let
	link = path: {
		source = config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.dir}/${path}";
	};
in
{
	options.dotfiles.terminal.enable = lib.mkOption {
		type = lib.types.bool;
		default = config.dotfiles.graphical;
		description = "GUI terminal emulator.";
	};

	config = lib.mkIf config.dotfiles.terminal.enable {
		home.packages = [ pkgs.wezterm ];

		xdg.configFile."wezterm" = link "wezterm";
	};
}
