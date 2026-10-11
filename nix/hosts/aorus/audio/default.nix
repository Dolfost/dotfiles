{ config, lib, ... }: {
	# The Scarlett is the guitar interface. It has to sit on a CPU-attached USB
	# port (the rear USB-C or a red USB-A on the B850M AORUS ELITE): behind the
	# Realtek hub on the chipset controller a 64-frame quantum crackles no matter
	# what, and that hub freezes everything else on it (keyboard, mouse) when the
	# Scarlett is unplugged (2026-10-11).
	services.pipewire.wireplumber.extraConfig."30-scarlett" = {
		"monitor.alsa.rules" = [
			# Never let its nodes suspend: a suspended node makes the first note
			# after a pause arrive late, with a click, while the device spins back
			# up.
			{
				matches = [ { "alsa.card_name" = "~Scarlett.*"; } ];
				actions.update-props = { "session.suspend-timeout-seconds" = 0; };
			}
			# Extra frames queued in the device, on top of the one period of slack
			# USB devices get anyway. At 64 frames REAPER still misses a cycle every
			# few seconds and with this the output never underruns; 64 without it was
			# only ever tried behind the hub. Costs 128 frames (2.9 ms) of output
			# latency.
			{
				matches = [ { "node.name" = "~alsa_output\\.usb-Focusrite_Scarlett.*"; } ];
				actions.update-props = { "api.alsa.headroom" = 128; };
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
