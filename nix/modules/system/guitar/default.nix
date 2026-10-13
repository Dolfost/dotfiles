# Low-latency music making: the JACK API for DAWs, served by pipewire.
# The rate/quantum tuning lives in ../audio.
{ config, ... }:

{
	services.pipewire.jack.enable = true;

# DAWs and plugin hosts ask for a 64-frame buffer (1.5 ms at ../audio's 44.1
# kHz) and pull the graph down to it while they run; everything else keeps
# the default quantum. ../audio's min-quantum is what allows it. Whether 64
# is clean depends on the USB path to the interface; see the Scarlett rule
# below.
	services.pipewire.extraConfig.jack."10-guitar-latency" = {
		"jack.properties" = {
			"node.latency" = "64/44100";
		};
	};

# The interface is a Scarlett Solo 4th Gen; it moves with the rig, so its
# rules live here. Never let its nodes suspend: a suspended node makes the
# first note after a pause arrive late, with a click, while the device spins
# back up. The output keeps 128 extra frames queued in the device, on top of
# the one period USB devices get anyway: at 64 frames a DAW misses the odd
# cycle, and with this slack the device never underruns, while without it a
# late cycle starves the USB queue and crackles with no xrun counted
# anywhere. Costs 128 frames (2.9 ms) of output latency. The Scarlett also
# has to hang off a CPU-attached USB port, not a hub on the chipset
# controller; which ports those are is host knowledge (hosts/<host>/audio).
#
# The Scarlett must also be the graph's clock. WirePlumber hands every USB
# capture node on device 0 the same driver priority (2100), so when a DAW
# links the Scarlett and another USB mic into one graph PipeWire breaks the
# tie by graph order. Whenever the mic wins, the Scarlett capture follows a
# foreign full-speed clock at 64 frames, comes up one frame short about twice
# a second, and PipeWire restarts the stream: a click every 0.5 s on the
# guitar that only the journal reports, as "snd_pcm_mmap_commit error ...
# Broken pipe" (2026-10-13). Only the driver priority is raised;
# priority.session would make the Scarlett the default microphone.
	services.pipewire.wireplumber.extraConfig."30-scarlett" = {
		"monitor.alsa.rules" = [
		{
			matches = [ { "alsa.card_name" = "~Scarlett.*"; } ];
			actions.update-props = { "session.suspend-timeout-seconds" = 0; };
		}
		{
			matches = [ { "node.name" = "~alsa_output\\.usb-Focusrite_Scarlett.*"; } ];
			actions.update-props = { "api.alsa.headroom" = 128; };
		}
		{
			matches = [ { "alsa.card_name" = "~Scarlett.*"; "api.alsa.pcm.stream" = "capture"; } ];
			actions.update-props = { "priority.driver" = 3000; };
		}
		];
	};

# Deliberately not mkForce: a host that turns rtkit off while importing
# guitar should get a conflict error, not a silent win.
	security.rtkit.enable = true;

# Realtime headroom for JACK clients: lock sample buffers, allow RT priority
# even for clients that bypass rtkit, and let them raise their own nice.
	security.pam.loginLimits = [
	{ domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
	{ domain = "@audio"; item = "rtprio"; type = "-"; value = "99"; }
	{ domain = "@audio"; item = "nice"; type = "-"; value = "-19"; }
	];
	users.users.${config.dotfiles.user}.extraGroups = [ "audio" ];
}
