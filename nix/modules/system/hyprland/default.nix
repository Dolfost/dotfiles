# Hyprland session: compositor, lockscreen, portal. A display manager
# (../ly) launches it.
{ pkgs, ... }:

{
	programs.hyprland = {
		enable = true;
		withUWSM = true;
		xwayland.enable = true;
	};
	programs.hyprlock.enable = true;

	xdg.portal = {
		enable = true;
		extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
	};
}
