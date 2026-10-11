{ config, lib, ... }: {
	# The Scarlett (modules/system/guitar) has to sit on a CPU-attached USB port:
	# the rear USB-C or a red USB-A on this B850M AORUS ELITE. Behind the Realtek
	# hub on the chipset controller a 64-frame quantum crackles no matter the
	# headroom, and that hub freezes everything else on it (keyboard, mouse) when
	# the Scarlett is unplugged (2026-10-11).

	home-manager.users.${config.dotfiles.user}.dotfiles = {
		# This machine's audio: the mic chain follows the Fifine, HDMI out gets no
		# processing.
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
