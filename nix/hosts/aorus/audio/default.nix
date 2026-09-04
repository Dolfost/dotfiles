{ config, lib, ... }: {
	home-manager.users.${config.dotfiles.user}.dotfiles = {
		# This machine's audio: the mic chain follows the Fifine, HDMI out
		# gets no processing.
		audio.autoload = [
			{
				kind = "input";
				device = "alsa_input.usb-3142_Fifine_Microphone-00.mono-fallback";
				"device-description" = "Fifine Microphone Mono";
				"device-profile" = "Microphone";
				"preset-name" = "mic noise red | autogain | stereo";
			}
		];
	};
}
