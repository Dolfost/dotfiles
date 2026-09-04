# Home halves of the features. Each one gates itself: on NixOS it follows
# what the host enabled (via osConfig), standalone everything defaults off
# and is flipped with dotfiles.<feature>.enable (or dotfiles.graphical for
# all the GUI app groups at once).
{ osConfig ? { }, config, lib, ... }:

{
	imports = [
		./shell
		./ssh
		./terminal
		./fonts
		./hyprland
		./browser
		./media
		./audio
		./openrgb
		./communication
		./guitar
		./gaming
	];

	options.dotfiles = {
		dir = lib.mkOption {
			type = lib.types.str;
			default = "/home/vladyslav/dotfiles";
			description = "The one checkout all config links point at, whoever's home this is.";
		};

		graphical = lib.mkOption {
			type = lib.types.bool;
			default = (osConfig.programs.hyprland.enable or false)
				|| (osConfig.services.desktopManager.gnome.enable or false);
			description = "This home sits on a host with a graphical session; the GUI app groups follow it.";
		};
	};

	# Shared wallpapers for whatever desktop runs: GNOME's picker scans
	# ~/.local/share/backgrounds, hyprpaper points there too.
	config = lib.mkIf config.dotfiles.graphical {
		xdg.dataFile."backgrounds".source =
			config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.dir}/wallpapers";
	};
}
