# Bench half of the diy module (the apps live in modules/user/diy): the host
# side of talking to boards over USB. Importing it is the opt-in; the user
# module follows dotfiles.diy.enable through osConfig.
{ config, lib, pkgs, ... }:

{
	options.dotfiles.diy.enable = lib.mkOption {
		type = lib.types.bool;
		default = true;
		description = "Serial and programmer access for the workbench; the user diy module follows it.";
	};

	config = lib.mkIf config.dotfiles.diy.enable {
		# USB-serial adapters and a board's own CDC port (/dev/ttyUSB*,
		# /dev/ttyACM*) are root:dialout and nothing tags them for the seat the
		# way uaccess does for raw USB devices, so group membership is the only
		# way in.
		users.users.${config.dotfiles.user}.extraGroups = [ "dialout" "plugdev" ];

		# picotool's rules open a Pico in BOOTSEL mode (2e8a:0003 and friends)
		# to the seated user via uaccess and to plugdev otherwise. The group
		# exists so an ssh session can flash too, and so udev stops logging an
		# unknown group on every plug.
		users.groups.plugdev = { };
		services.udev.packages = [ pkgs.picotool ];

		environment.systemPackages = with pkgs; [
			picotool # Pico flashing and inspection over the BOOTSEL interface
			tio      # serial terminal: `tio /dev/ttyACM0`, reconnects by itself
		];
	};
}
