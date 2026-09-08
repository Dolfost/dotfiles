# Home halves of the features. Each one gates itself: on NixOS it follows what
# the host enabled (via osConfig), standalone everything defaults off and is
# flipped with dotfiles.<feature>.enable (or dotfiles.graphical for all the GUI
# app groups at once).
{ osConfig ? { }, config, lib, pkgs, ... }:

let
	# The repo-link convention behind every config file here: the file becomes a
	# symlink into the live checkout, not the store, so in-place edits (GUI apps
	# included) land straight in git. Exported through HM's config.lib — the
	# same extension point mkOutOfStoreSymlink itself comes from — so every
	# module reads it as config.lib.dotfiles.link instead of redefining it.
	link = path: {
		source = config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.dir}/${path}";
	};
in
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

	config = lib.mkMerge [
		{ lib.dotfiles.link = link; }

		(lib.mkIf config.dotfiles.graphical {
			# Shared wallpapers for whatever desktop runs: GNOME's picker scans
			# ~/.local/share/backgrounds, hyprpaper points there too.
			xdg.dataFile."backgrounds" = link "wallpapers";

			# Numlock is on everywhere (ly, GNOME, Hyprland all enable it) but its
			# LED is noise: ~/.config/xkb shadows xkeyboard-config's compat/lednum
			# so the Num Lock indicator binds to nothing and xkbcommon compositors
			# keep the LED dark. Console half: udev rule in modules/system/input.
			xdg.configFile."xkb" = link "xkb";

			# Wrapper config for the yazi portal file picker (host side:
			# modules/system/file-picker). Graphical-wide: any DE may route
			# FileChooser to termfilechooser, and wezterm follows the same gate.
			xdg.configFile."xdg-desktop-portal-termfilechooser" =
				link "xdg-desktop-portal-termfilechooser";

			# One cursor everywhere: pointerCursor exports XCURSOR_THEME/SIZE
			# (Hyprland itself and Wayland-native apps) and links the theme into
			# ~/.icons and ~/.local/share/icons (XWayland apps like Steam). GNOME
			# and portal-served GTK apps read dconf instead, gtk.enable writes the
			# settings.ini fallback GTK apps use under Hyprland.
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
		})
	];
}
