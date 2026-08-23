# Lenovo LOQ laptop. NOT INSTALLED YET — see ./hardware-configuration.nix.
#
# No storage.nix here, and the firewall stays at its default (on).
{ ... }:

{
	imports = [
		./hardware-configuration.nix
		../../modules/common.nix
		../../modules/desktop.nix
	];

	networking.hostName = "loq";

	services.power-profiles-daemon.enable = true;
	hardware.bluetooth.enable = true;

	# Set this to the release you actually install with, then never change it.
	system.stateVersion = "26.05";
}
