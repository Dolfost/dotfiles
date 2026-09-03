# Hyprland session: compositor, lockscreen, portal. A display manager (../ly)
# launches it.
{ config, lib, pkgs, ... }:

{
	programs.hyprland = {
		enable = true;
		withUWSM = true;
		xwayland.enable = true;
	};

	# If this host also streams with Sunshine, capture the session via
	# wlr-screencopy and publish the virtual display prep
	# (./sunshine_virtual_display.nix) - used by the bare app below and by
	# whatever else wants to stream at the client's resolution.
	services.sunshine.settings.capture =
		lib.mkIf config.services.sunshine.enable "wlr";
	dotfiles.sunshine.virtualDisplayPrep =
		lib.mkIf config.services.sunshine.enable (
			let
				virtualDisplay = import ./sunshine_virtual_display.nix { inherit lib pkgs; };
			in
			{
				do = "${virtualDisplay} start";
				undo = "${virtualDisplay} stop";
			}
		);
	services.sunshine.applications.apps =
		lib.mkIf config.services.sunshine.enable [
			{
				name = "Virtual display";
				output = "${config.users.users.${config.dotfiles.user}.home}/.hyprland_sunshine_output.txt";
				prep-cmd = [ config.dotfiles.sunshine.virtualDisplayPrep ];
				exit-timeout = 5;
				wait-all = true;
			}
		];

	environment.etc."xdg/uwsm/env".text = ''
		[ -f /etc/set-environment ] && . /etc/set-environment
		[ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ] &&
			. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
	'';
	programs.hyprlock.enable = true;

	# Secret Service for the session: gnome-keyring answers org.freedesktop.
	# secrets on D-Bus, gcr draws its unlock/create-keyring prompts. Chromium's
	# keyring autodetection doesn't know XDG_CURRENT_DESKTOP=Hyprland, so
	# Electron apps additionally need --password-store=gnome-libsecret.
	services.gnome.gnome-keyring.enable = true;
	environment.systemPackages = [ pkgs.gcr ];

	xdg.portal = {
		enable = true;
		extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
	};
}
