# The EcoFlow Delta 3 Max Plus, watched through the phone: tissot's
# Bluetooth link to it is the NUT server (nix/hosts/tissot), this box is a
# client that hibernates on low battery and runs the outage levers. The USB
# link (HID + the CDC port with live wattage) is gone from here: the phone
# stays up through an outage, this one does not. The spinning disks are the
# two media drives; the NVMe carries everything else. Low battery hibernates
# into the 32 GB swap partition. The box is a server during an outage, so no
# idle action here.
#
# Every knob of modules/system/power and modules/user/power is listed, at
# its default where nothing says otherwise, so tuning is an edit here.
{ config, inputs, pkgs, ... }:

let
	facts = import ../../../facts.nix;
in
{

	# The publishing token, shared with the phone's notifier: the phone's
	# secrets file lists this host's key as a reader (.sops.yaml).
	sops.secrets."ntfy/token".sopsFile = ../../../secrets-tissot.yaml;

	# upst, the terminal dashboard, pointed at the phone: the UPS it serves and
	# the recorder it runs (nix/hosts/tissot), so upst opens with the last day
	# of charts and events wherever it runs. settings becomes
	# /etc/upst/config.toml (~/.config/upst/config.toml and flags win). Keys:
	# github.com/Dolfost/upst/blob/main/docs/setup.md
	environment.systemPackages = [ inputs.upst.packages.${pkgs.stdenv.hostPlatform.system}.default ];
	environment.etc."upst/config.toml".source = (pkgs.formats.toml { }).generate "upst.toml" {
		targets = [ "ups@${facts.hosts.tissot.lan_ipv4}" ];
		recorder = facts.hosts.tissot.lan_ipv4;
		charge-style = "battery"; # battery, lcd, segments, blocks or bar; b cycles in upst
		history = "48h"; # loaded from the recorder at start, and kept while upst runs
	};

	dotfiles.power = {
		ups = {
			enable = true;
			# The phone's NUT server; its thresholds (20 %, 300 s) decide low battery.
			remote = {
				system = "ups@${facts.hosts.tissot.lan_ipv4}";
				inherit (facts.hosts.tissot.nut) user password;
			};
			onLowBattery = "hibernate"; # or "poweroff"
		};
		outage = {
			hibernateAfterLock = 2; # minutes with the screen locked, on battery, before hibernating; the phone wakes it 10 min after the grid is back (null: only at low battery)
			# Its own ntfy topic: "aorus hibernates" with the EcoFlow's numbers, "aorus is back" on resume.
			notify = {
				url = "http://${facts.hosts.tissot.lan_ipv4}:2586"; # the LAN address: an outage is no time to depend on the tailnet's DNS
				topic = "aorus";
				tokenFile = config.sops.secrets."ntfy/token".path;
				click = "https://dash.${facts.ts_network}"; # a tap opens the phone's dashboard
			};
			# The phone's dashboard (nix/hosts/tissot/power/dashboard.nix) may hold,
			# release and trigger the hibernate, as the power-remote user over ssh.
			remote = [ facts.hosts.tissot.remote_key ];
			cpuProfile = "power-saver"; # power-profiles-daemon profile on battery (null: leave CPU alone)
			# The two spinning media drives, by filesystem label (the same labels
			# ./storage mounts); the lever finds the disk behind each.
			spinDown = [
				"/dev/disk/by-label/media2.5" # /storage/2.5
				"/dev/disk/by-label/media3.5" # /storage/3.5
			];
			spinDownAfter = 10; # minutes idle before a spun-down disk stops again (1..20)
		};
	};

	home-manager.users.${config.dotfiles.user}.dotfiles.power = {
		enable = true; # follows ups.enable above by default
		warnCharge = 30; # critical notification at this percent (default: lowBattery.charge + 10; null: off)
		outage = {
			# DP-1 at 180 Hz keeps the dGPU memory clock up whenever the screen
			# moves; 60 Hz is about 10 W less.
			refreshRate = 60; # every enabled monitor on battery (null: keep modes)
			brightness = null; # DDC brightness 0..100 for external panels on battery (null: leave)
			stopUnits = [ "nicotine.service" "crafty.service" ]; # user units stopped on battery
			lockTimeout = 120; # idle seconds before the session locks on battery (everyday: 600 in hypr/hypridle.conf); hibernateAfterLock counts from there
			dpmsTimeout = 120; # idle seconds before the screen turns off on battery (0: never)
			idle = {
				timeout = 1200; # idle seconds before idle.command
				command = null; # e.g. "systemctl hibernate"; null keeps the server up
			};
			# Discord (Vesktop) is the one app that stays busy while hidden; frozen it
			# costs nothing, and nothing from it arrives until the next input.
			freezeApps = [ "vesktop" ]; # app-*.scope substrings frozen while idle on battery
			freezeAfter = 120; # idle seconds before they freeze (thaw on input or grid)
		};
	};
}
