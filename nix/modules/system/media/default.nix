# System half of the media module (the apps live in modules/user/media);
# kernel-side pieces land here.
{ lib, ... }: {
	imports = [ ../v4l2loopback ];

	# Which disk has room for recordings is host knowledge; the user media module
	# reads this for OBS and falls back to ~/Videos.
	options.dotfiles.media.recordDir = lib.mkOption {
		type = lib.types.nullOr lib.types.str;
		default = null;
		description = "Host override for where OBS saves recordings.";
	};

	# Somewhere for OBS's "Start Virtual Camera" to stream.
	config.dotfiles.v4l2loopback.devices.obs = { nr = 10; label = "OBS Virtual Camera"; };
}
