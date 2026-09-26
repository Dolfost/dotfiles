{ lib, pkgs, ... }:
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

		# The DualSense's USB audio (speaker, jack, mic, haptics) is 48 kHz only.
		# Pinned to the global rate above the node never starts ("Start error:
		# Operation not supported") and anything routed to it stalls - browsers
		# buffer forever. Fragments merge by file name, so this wins over 10-*. The
		# hardware volume it also needs is the udev rule below.
		wireplumber.extraConfig."11-dualsense-rate" = {
			"monitor.alsa.rules" = [
			{
				matches = [ { "alsa.card_name" = "~DualSense.*"; } ];
				actions.update-props = {
					"audio.rate" = 48000;
					"audio.allowed-rates" = [ 48000 ];
				};
			}
			];
		};
	};

	# Over USB the DualSense is also a sound card whose hardware volume (the
	# HID-backed 'PCM Playback Volume' snd-usb-audio exposes) comes up at 0 on
	# every plug-in, and its UCM profile has no mixer element for PipeWire to
	# manage it. Park it at 0 dB once; PipeWire does the soft volume.
	services.udev.extraRules = ''
		ACTION=="add", SUBSYSTEM=="sound", KERNEL=="controlC*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6|0df2", RUN+="${pkgs.alsa-utils}/bin/amixer -c $attr{device/number} sset PCM 100"
	'';

	# The default for every host; features that depend on realtime scheduling
	# (../guitar) pin it with a plain definition.
	security.rtkit.enable = lib.mkDefault true;
}
