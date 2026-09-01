# Low-latency music making: the JACK API for DAWs, served by pipewire.
# The rate/quantum tuning lives in ../audio.
{ config, ... }:

{
	services.pipewire.jack.enable = true;

	# Deliberately not mkForce: a host that turns rtkit off while importing
	# guitar should get a conflict error, not a silent win.
	security.rtkit.enable = true;

	# Realtime headroom for JACK clients: lock sample buffers, allow RT priority
	# even for clients that bypass rtkit.
	security.pam.loginLimits = [
		{ domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
		{ domain = "@audio"; item = "rtprio"; type = "-"; value = "99"; }
	];
	users.users.${config.dotfiles.user}.extraGroups = [ "audio" ];
}
