# The EcoFlow Delta 3 Max Plus on USB (3746:ffff). It shows up as a HID
# power device that NUT's EcoFlow subdriver claims (status, charge,
# runtime) plus a CDC serial port with the live wattage, which NUT reads
# from 2.8.6 on (built from master below). The spinning disks are the two
# media drives; the NVMe carries everything else. Low battery hibernates into
# the 32 GB swap partition. The box is a server during an outage, so no idle
# action here.
#
# Every knob of modules/system/power and modules/user/power is listed, at
# its default where nothing says otherwise, so tuning is an edit here.
{ config, inputs, pkgs, ... }:

{
	imports = [ inputs.upst.nixosModules.default ];

	# NUT from its development branch until 2.8.6 reaches nixpkgs: 2.8.4 leaks
	# 128 bytes a poll in the EcoFlow subdriver (measured here: 4 KB a minute),
	# and only the new one has ecoflow_cdc_port. See packages/nut.nix.
	power.ups.package = pkgs.callPackage ../../../packages/nut.nix { };

	# The CDC port under a fixed name: /dev/serial/by-id/ would work too, but
	# that name carries the unit's serial number.
	services.udev.extraRules = ''
		SUBSYSTEM=="tty", ATTRS{idVendor}=="3746", ATTRS{idProduct}=="ffff", SYMLINK+="ecoflow-cdc"
	'';

	# upst, the terminal dashboard for this UPS, and its recorder, which keeps a
	# journal in /var/lib/upst so upst opens with the last day of charts and
	# events. settings becomes /etc/upst/config.toml: the defaults for every upst
	# here (~/.config/upst/config.toml and flags win), and the recorder's own
	# under record. Keys: github.com/Dolfost/upst/blob/main/docs/setup.md
	services.upst = {
		enable = true;
		settings = {
			targets = [ "ups@localhost" ]; # NUT's name for it (default: every UPS on localhost)
			charge-style = "battery"; # battery, lcd, segments, blocks or bar; b cycles in upst
			history = "48h"; # loaded from the recorder at start, and kept while upst runs
			record = {
				interval = "5s"; # time between polls
				keep = "7d"; # history kept on disk
				listen = [ ]; # besides /run/upst/upst.sock, e.g. "0.0.0.0:3494" for upst on loq
			};
		};
	};

	dotfiles.power = {
		ups = {
			enable = true;
			driver = "usbhid-ups"; # NUT driver
			port = "auto"; # scan USB for it
			description = "EcoFlow Delta 3 Max Plus";
			directives = [
				"vendorid = 3746"
				"productid = ffff"
				# Live watts, voltage, frequency and temperatures from the CDC port,
				# polled with a read-only request. Upstream checked it on a River 3
				# Plus; this unit (EMS firmware 2.1.1.104) answers it too. HID stays
				# the source for status, charge and runtime.
				"ecoflow_cdc_port = /dev/ecoflow-cdc"
			]; # extra ups.conf lines
			lowBattery = {
				charge = 20; # percent at or below: low battery (null: device's own flag)
				runtime = 300; # seconds left at or below: low battery (null: device's own flag)
			};
			onLowBattery = "hibernate"; # or "poweroff"
		};
		outage = {
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
