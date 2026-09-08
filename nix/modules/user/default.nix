# Home halves of the features. Each one gates itself: on NixOS it follows what
# the host enabled (via osConfig), standalone everything defaults off and is
# flipped with dotfiles.<feature>.enable (or dotfiles.graphical for all the GUI
# app groups at once).
{ osConfig ? { }, config, lib, pkgs, ... }:

{
	imports = [
		../system/dotfiles
		./shell
		./ssh
		./desktop
		./fonts
		./hyprland
		./browser
		./media
		./audio
		./openrgb
		./communication
		./work
		./guitar
		./gaming
	];

	# Shared wallpapers for whatever desktop runs: GNOME's picker scans
	# ~/.local/share/backgrounds, hyprpaper points there too.
	config = lib.mkIf config.dotfiles.graphical {
		xdg.dataFile."backgrounds".source =
			config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.dir}/wallpapers";

		# Wrapper config for the yazi portal file picker (host side:
		# modules/system/file-picker). Graphical-wide: any DE may route FileChooser
		# to termfilechooser, and wezterm follows the same gate.
		xdg.configFile."xdg-desktop-portal-termfilechooser".source =
			config.lib.file.mkOutOfStoreSymlink
				"${config.dotfiles.dir}/xdg-desktop-portal-termfilechooser";

		# One cursor everywhere: pointerCursor exports XCURSOR_THEME/SIZE (Hyprland
		# itself and Wayland-native apps) and links the theme into ~/.icons and
		# ~/.local/share/icons (XWayland apps like Steam). GNOME and portal-served
		# GTK apps read dconf instead, gtk.enable writes the settings.ini fallback
		# GTK apps use under Hyprland.
		home.pointerCursor = {
			package = pkgs.apple-cursor;
			name = "macOS";
			size = 24;
			gtk.enable = true;
		};
		gtk.enable = true;
		dconf.settings."org/gnome/desktop/interface" = {
			cursor-theme = "macOS";
			cursor-size = 24;
			color-scheme = "default";
		};
	};
}
