# Lenovo LOQ laptop. NOT INSTALLED YET — see ./hardware-configuration.nix.
#
# No storage.nix here, and the firewall stays at its default (on).
{ ... }:

{
	imports = [
		./hardware-configuration.nix
		./storage
		./ssh
		../../modules/system
		../../modules/system/nvidia-gpu
		../../modules/system/hyprland
		../../modules/system/gnome
		../../modules/system/ly
		../../modules/system/gaming
		../../modules/system/openrgb
		../../modules/system/android
	];

	services.power-profiles-daemon.enable = true;
	hardware.bluetooth.powerOnBoot = true;

	# Set this to the release you actually install with, then never change it.
	system.stateVersion = "26.05";
}
