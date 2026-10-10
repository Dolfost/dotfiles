# System half of the media module (the apps live in modules/user/media);
# kernel-side pieces land here.
#
# v4l2loopback: virtual camera devices. /dev/video10 is where OBS's "Start
# Virtual Camera" streams, /dev/video11 is the phone camera (system/android's
# phone-cam). exclusive_caps makes browsers and Discord accept them as real
# webcams; video_nr parks them clear of real capture devices.
{ config, lib, ... }: {
	# Which disk has room for recordings is host knowledge; the user media module
	# reads this for OBS and falls back to ~/Videos.
	options.dotfiles.media.recordDir = lib.mkOption {
		type = lib.types.nullOr lib.types.str;
		default = null;
		description = "Host override for where OBS saves recordings.";
	};

	config.boot = {
		extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
		kernelModules = [ "v4l2loopback" ];
		extraModprobeConfig = ''
			options v4l2loopback devices=2 video_nr=10,11 card_label="OBS Virtual Camera,Phone Camera" exclusive_caps=1,1
		'';
	};
}
