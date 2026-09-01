# GNOME as the fallback session. No display manager of its own — ly
# (../ly) lists it.
{ pkgs, ... }:

{
	services.desktopManager.gnome.enable = true;
	services.gnome.core-apps.enable = false;
	environment.gnome.excludePackages = with pkgs; [
		gnome-tour
		gnome-user-docs
	];
}
