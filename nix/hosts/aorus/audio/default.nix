{ config, lib, ... }: {
	# The Scarlett is the guitar interface. Never let its nodes suspend: a
	# suspended node makes the first note after a pause arrive late, with a
	# click, while the device spins back up.
	services.pipewire.wireplumber.extraConfig."30-scarlett-no-suspend" = {
		"monitor.alsa.rules" = [
			{
				matches = [ { "alsa.card_name" = "~Scarlett.*"; } ];
				actions.update-props = { "session.suspend-timeout-seconds" = 0; };
			}
		];
	};

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
