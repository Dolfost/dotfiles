{ config, lib, ... }: {
	# The Scarlett (modules/system/guitar) has to sit on a CPU-attached USB port:
	# the rear USB-C or a red USB-A on this B850M AORUS ELITE. Behind the Realtek
	# hub on the chipset controller a 64-frame quantum crackles no matter the
	# headroom, and that hub freezes everything else on it (keyboard, mouse) when
	# the Scarlett is unplugged (2026-10-11).

	# The Fifine is a full-speed USB mic: its audio arrives in 1 ms lumps. When a
	# DAW pulls the graph to 64 frames (modules/system/guitar) and the mic is in
	# that graph (it is the default source, so WirePlumber links it to the DAW's
	# first input) it follows the Scarlett clock and comes up a few frames short
	# about twice a second. PipeWire restarts the stream, the restart blocks the
	# one realtime thread for longer than the Scarlett output's cushion, and the
	# guitar drops out: "hw:4c: snd_pcm_mmap_commit error ... Broken pipe" then
	# "hw:Genp: follower avail:3 ... resync" in the pipewire journal, ~2000 times
	# in 14 minutes (2026-10-24). This is the mirror of the 2026-10-13 click that
	# the Scarlett driver priority fixed: the follower is now the mic. 512 frames
	# of headroom keep the mic ahead of the graph; costs 12 ms on the mic only.
	services.pipewire.wireplumber.extraConfig."31-fifine-headroom" = {
		"monitor.alsa.rules" = [
		{
			matches = [ { "alsa.card_name" = "Fifine Microphone"; "api.alsa.pcm.stream" = "capture"; } ];
			actions.update-props = { "api.alsa.headroom" = 512; };
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
