# GNOME as the fallback session. No display manager of its own — ly
# (../ly) lists it.
{ config, lib, pkgs, ... }:

{
	services.desktopManager.gnome.enable = true;
	services.gnome.core-apps.enable = false;

	# If this host streams with Sunshine: mutter has no wlr-screencopy, so
	# capture goes through kms (hence capSysAdmin in ../gaming). Only a default -
	# a wlroots compositor on the same host (../hyprland) wins.
	services.sunshine.settings.capture =
		lib.mkIf config.services.sunshine.enable (lib.mkDefault "kms");

	# GNOME force-enables the ibus input method, whose autostart entry then also
	# runs in the Hyprland session and nags on every login. No IME input is used
	# here - plain XKB layouts work without it.
	i18n.inputMethod.enable = lib.mkForce false;
	environment.gnome.excludePackages = with pkgs; [
		gnome-tour
		gnome-user-docs
	];
}
