{ lib, ... }:
let
rate = 44100;
quantum = 256;
in
{
	services.pipewire = {
		enable = true;
		pulse.enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;

		extraConfig.pipewire."10-clock" = {
			"context.properties" = {
				"default.clock.rate" = rate;
				"default.clock.allowed-rates" = [ rate ];
				"default.clock.quantum" = quantum;
				"default.clock.min-quantum" = quantum;
				"default.clock.max-quantum" = quantum;
			};
		};

		# Apps record from "Virtual Microphone"; it mixes whatever is linked into
		# its input ports. Only direct port links (a patchbay, pw-link, carla) can
		# feed it - wireplumber cannot route playback streams into an
		# Audio/Source/Virtual node, so there is no automatic mic feed.
		extraConfig.pipewire."20-virtual-mic" = {
			"context.objects" = [
			{
				factory = "adapter";
				args = {
					"factory.name" = "support.null-audio-sink";
					"node.name" = "virtual-mic";
					"node.description" = "Virtual Microphone";
					"media.class" = "Audio/Source/Virtual";
					"audio.position" = [ "FL" "FR" ];
				};
			}
			];
		};

		wireplumber.extraConfig."10-alsa-rate" = {
			"monitor.alsa.rules" = [
			{
				matches = [ { "node.name" = "~alsa_(input|output)\\..*"; } ];
				actions.update-props = {
					"audio.rate" = rate;
					"audio.allowed-rates" = [ rate ];
				};
			}
			];
		};
	};

	# The default for every host; features that depend on realtime scheduling
	# (../guitar) pin it with a plain definition.
	security.rtkit.enable = lib.mkDefault true;
}
