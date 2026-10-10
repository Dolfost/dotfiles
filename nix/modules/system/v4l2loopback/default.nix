# Virtual cameras. v4l2loopback takes every device in one modprobe line (count,
# numbers, labels and caps as parallel lists), so features declare theirs here
# instead of each writing options that would clobber the others'. Imported by
# the features that need a device (media, android); a host without them gets no
# module. exclusive_caps makes browsers and Discord accept the devices as real
# webcams; numbers from 10 up stay clear of real capture devices.
{ config, lib, ... }:

let
	cfg = config.dotfiles.v4l2loopback;
	devices = lib.sort (a: b: a.nr < b.nr) (lib.attrValues cfg.devices);
	list = f: lib.concatMapStringsSep "," f devices;
in
{
	options.dotfiles.v4l2loopback.devices = lib.mkOption {
		type = lib.types.attrsOf (lib.types.submodule {
			options = {
				nr = lib.mkOption {
					type = lib.types.int;
					description = "N in /dev/videoN.";
				};
				label = lib.mkOption {
					type = lib.types.str;
					description = "The camera name apps show.";
				};
			};
		});
		default = { };
		description = "Virtual camera devices to create, keyed by the feature that owns them.";
	};

	config = lib.mkIf (devices != [ ]) {
		assertions = [
			{
				assertion = lib.allUnique (map (d: d.nr) devices);
				message = "dotfiles.v4l2loopback: two devices claim the same /dev/videoN.";
			}
		];
		boot = {
			extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
			kernelModules = [ "v4l2loopback" ];
			extraModprobeConfig = ''
				options v4l2loopback devices=${toString (lib.length devices)} video_nr=${list (d: toString d.nr)} card_label="${list (d: d.label)}" exclusive_caps=${list (d: "1")}
			'';
		};
	};
}
