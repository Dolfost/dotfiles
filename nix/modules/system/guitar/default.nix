# Low-latency music making: the JACK API for DAWs, served by pipewire.
# The rate/quantum tuning lives in ../audio.
{ config, ... }:

{
	services.pipewire.jack.enable = true;

	# DAWs and plugin hosts ask for a 64-frame buffer (1.5 ms at ../audio's
	# 44.1 kHz) and pull the graph down to it while they run; everything else
	# keeps the default quantum. ../audio's min-quantum is what allows it.
	services.pipewire.extraConfig.jack."10-guitar-latency" = {
		"jack.properties" = {
			"node.latency" = "64/44100";
		};
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
