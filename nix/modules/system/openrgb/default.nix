# The hardware side of RGB control: openrgb's udev rules for the USB
# controllers, and SMBus access (motherboard/RAM lighting) for the i2c
# group. Which lights do what is the user half - dotfiles.openrgb.
{ config, pkgs, ... }:

{
	services.udev.packages = [ pkgs.openrgb ];
	hardware.i2c.enable = true;
	users.users.${config.dotfiles.user}.extraGroups = [ "i2c" ];
}
