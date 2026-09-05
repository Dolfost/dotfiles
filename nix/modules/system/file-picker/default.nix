# Yazi (in wezterm, via the termfilechooser portal) as the system file
# picker. Self-contained and imported by every DE module (../hyprland,
# ../gnome) so no session is left with a half-wired picker; NixOS dedupes
# the shared import. The user half (wrapper config, wezterm) follows
# dotfiles.graphical, so it is present whenever any DE is.
{ pkgs, ... }:

{
	xdg.portal = {
		enable = true;
		extraPortals = [ pkgs.xdg-desktop-portal-termfilechooser ];
		# GNOME needs its own entry: xdg-desktop-portal-gnome ships a
		# gnome-portals.conf that outranks the common fallback.
		config =
			let
				yaziPicker."org.freedesktop.impl.portal.FileChooser" =
					[ "termfilechooser" ];
			in
			{
				common = yaziPicker;
				hyprland = yaziPicker;
				gnome = yaziPicker;
			};
	};

	# Neither toolkit asks the portal for file dialogs by default outside a
	# sandbox: GTK needs GTK_USE_PORTAL, Qt (Telegram, nomacs) needs the
	# xdgdesktopportal platform theme.
	environment.sessionVariables = {
		GTK_USE_PORTAL = "1";
		QT_QPA_PLATFORMTHEME = "xdgdesktopportal";
	};
}
