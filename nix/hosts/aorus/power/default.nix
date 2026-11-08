# The EcoFlow Delta 3 Max Plus on USB (3746:ffff). It shows up as a HID
# power device that NUT's EcoFlow subdriver claims (status, charge,
# runtime) plus a CDC serial port with the live wattage, which NUT reads
# only from 2.8.6 on. The spinning disks are the two media drives; the
# NVMe carries everything else. Low battery hibernates into the 32 GB swap
# partition. The box is a server during an outage, so no idle action here.
#
# Every knob of modules/system/power and modules/user/power is listed, at
# its default where nothing says otherwise, so tuning is an edit here.
{ config, ... }:

{
	dotfiles.power = {
		ups = {
			enable = true;
			driver = "usbhid-ups"; # NUT driver
				port = "auto"; # scan USB for it
				description = "EcoFlow Delta 3 Max Plus";
			directives = [ "vendorid = 3746" "productid = ffff" ]; # extra ups.conf lines
				lowBattery = {
					charge = 30; # percent at or below: low battery (null: device's own flag)
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
			warnCharge = 40; # critical notification at this percent (default: lowBattery.charge + 10; null: off)
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
			};
	};
}
