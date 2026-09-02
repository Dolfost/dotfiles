# Home halves of the features. Each one gates itself: on NixOS it follows
# what the host enabled (via osConfig), standalone everything defaults off
# and is flipped with dotfiles.<feature>.enable (or dotfiles.graphical for
# all the GUI app groups at once).
{ osConfig ? { }, lib, ... }:

{
	imports = [
		./shell
		./terminal
		./fonts
		./hyprland
		./browser
		./media
		./audio
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
}
