# System half of the media module (the apps live in modules/user/media);
# kernel-side pieces land here.
#
# v4l2loopback: virtual camera device, so OBS's "Start Virtual Camera" has
# somewhere to stream. exclusive_caps makes browsers and Discord accept it as a
# real webcam; video_nr parks it at /dev/video10, clear of real capture
# devices.
{ config, ... }: {
	boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
	boot.kernelModules = [ "v4l2loopback" ];
	boot.extraModprobeConfig = ''
		options v4l2loopback devices=1 video_nr=10 card_label="OBS Virtual Camera" exclusive_caps=1
	'';
}
