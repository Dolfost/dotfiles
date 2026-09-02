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

	xdg.portal = {
		enable = true;
		extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
	};
}
