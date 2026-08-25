# CoolerControl. Unlike everything in services.nix this isn't a container: the
# daemon runs as root and drives PWM through /sys/class/hwmon directly, so what
# gets version-controlled is its /etc config rather than an image.
#
# ./coolercontrol/ is the NixOS snapshot, and it is deliberately a copy of
# ../../../etc/coolercontrol/ rather than a reference to it — that one belongs
# to the Arch install this machine still dual-boots. The two are free to drift:
# CoolerControl derives its device UIDs by hashing device characteristics, so a
# different kernel and driver set can legitimately enumerate hwmon differently.
{ lib, ... }:

{
	programs.coolercontrol.enable = true;

	# Copied (mode) rather than symlinked, because coolercontrold rewrites
	# config.toml every time a setting changes in the UI and a /nix/store
	# symlink is read-only. The cost is that activation resets these to the
	# tracked copy, so tune first and copy back before the next rebuild — see
	# ./coolercontrol/README.md.
	#
	# Listed per file, never as a directory: the daemon also generates .passwd
	# and its TLS pair in /etc/coolercontrol at runtime, and those are untracked
	# host secrets that have to stay writable alongside these.
	environment.etc = lib.genAttrs [
		"coolercontrol/config.toml"      # devices, fan curves, speed profiles
		"coolercontrol/config-ui.json"   # web UI layout
		"coolercontrol/alerts.json"
		"coolercontrol/calibrations.json"
		"coolercontrol/modes.json"
	] (name: {
		source = ./${name};
		mode = "0644";
	});
}
