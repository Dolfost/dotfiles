# Hyprland session: compositor, lockscreen, portal. A display manager
# (../ly) launches it.
{ pkgs, ... }:

{
	programs.hyprland = {
		enable = true;
		withUWSM = true;
		xwayland.enable = true;
	};

	environment.etc."xdg/uwsm/env".text = ''
		[ -f /etc/set-environment ] && . /etc/set-environment
		[ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ] &&
			. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
	'';
	programs.hyprlock.enable = true;

	# Secret Service for the session: gnome-keyring answers
	# org.freedesktop. secrets on D-Bus, gcr draws its
	# unlock/create-keyring prompts. Chromium's keyring autodetection
	# doesn't know XDG_CURRENT_DESKTOP=Hyprland, so Electron apps
	# additionally need --password-store=gnome-libsecret.
	services.gnome.gnome-keyring.enable = true;
	environment.systemPackages = [ pkgs.gcr ];

	xdg.portal = {
		enable = true;
		extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
	};
}
