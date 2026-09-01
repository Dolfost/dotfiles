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
