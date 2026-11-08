# A UPS on USB, and what the machine does while it runs on it. Detection is
# Network UPS Tools: usbhid-ups polls the UPS, upsmon turns its on-battery
# and on-line events into `systemctl start|stop power-outage.target`, and
# every saving is a oneshot under that target - ExecStart applies it,
# ExecStop undoes it. The target also publishes the state to
# /run/power/source ("grid" or "battery"), which is how the user session
# (../../user/power) follows along without talking to NUT itself.
#
# Low battery is our threshold, not the device's: the EcoFlow reports its
# app discharge limit as battery.charge.low (0 while that limit is off), so
# the driver would never raise LB by itself. On LB upsmon runs onLowBattery -
# hibernate by default, so the session comes back when the grid does. The
# UPS cannot be told to cut its output from here (the EcoFlow ignores the
# HID shutdown commands), so after a halt the box stays off until the power
# button or WOL.
#
# upsd listens on loopback only and the upsmon password is generated at
# boot: reads need no login and nothing else listens, so it is not a secret
# worth sops.
{ config, lib, pkgs, ... }:

let
	cfg = config.dotfiles.power;
	inherit (lib) mkOption mkEnableOption types mkIf optional optionalAttrs;

	stateDir = "/run/power";
	passwordFile = "/run/nut/password";
	swap = lib.findFirst (sd: sd ? device) null config.swapDevices;
	systemctl = "${pkgs.systemd}/bin/systemctl";
	powerprofilesctl =
		lib.getExe' config.services.power-profiles-daemon.package "powerprofilesctl";
	hdparm = "${pkgs.hdparm}/bin/hdparm";

	# spinDown entries may be partitions (a filesystem's by-label device) or
	# whole disks; hdparm wants the disk, so each is resolved to its parent.
	forEachDisk = body: ''
		for dev in ${lib.escapeShellArgs cfg.outage.spinDown}; do
			node=$(${pkgs.coreutils}/bin/readlink -f "$dev") || continue
			parent=$(${pkgs.util-linux}/bin/lsblk -no PKNAME "$node" | ${pkgs.coreutils}/bin/head -1)
			disk=/dev/''${parent:-''${node#/dev/}}
			${body}
		done
	'';

	# upsmon's NOTIFYCMD, run as the unprivileged nutmon user; the polkit rule
	# below lets it drive exactly this one target. Everything else upsmon
	# reports goes to syslog only.
	notify = pkgs.writeShellScript "power-ups-notify" ''
		case "$NOTIFYTYPE" in
			ONBATT) exec ${systemctl} start power-outage.target ;;
			ONLINE) exec ${systemctl} stop power-outage.target ;;
		esac
	'';

	# One saving = one unit under the target: start applies, stop reverts.
	lever = name: description: exec: {
		"power-outage-${name}" = {
			inherit description;
			partOf = [ "power-outage.target" ];
			wantedBy = [ "power-outage.target" ];
			serviceConfig = {
				Type = "oneshot";
				RemainAfterExit = true;
				ExecStart = pkgs.writeShellScript "power-outage-${name}-start" exec.start;
				ExecStop = pkgs.writeShellScript "power-outage-${name}-stop" exec.stop;
			};
		};
	};
in
{
	options.dotfiles.power = {
		ups = {
			enable = mkEnableOption "a USB UPS monitored with NUT, and the outage target";
			driver = mkOption {
				type = types.str;
				default = "usbhid-ups";
				description = "NUT driver for the UPS.";
			};
			port = mkOption {
				type = types.str;
				default = "auto";
				description = "NUT port for the driver; auto scans USB.";
			};
			description = mkOption {
				type = types.str;
				default = "UPS";
				description = "What NUT calls the device.";
			};
			directives = mkOption {
				type = types.listOf types.str;
				default = [ ];
				example = [ "vendorid = 3746" "productid = ffff" ];
				description = "Extra ups.conf lines for the driver: how to find this UPS.";
			};
			lowBattery = {
				charge = mkOption {
					type = types.nullOr types.int;
					default = 20;
					description = ''
						Charge percent at or below which the battery counts as low
						(upsmon then runs onLowBattery). null leaves it to the device.
					'';
				};
				runtime = mkOption {
					type = types.nullOr types.int;
					default = 300;
					description = ''
						Estimated seconds left at or below which the battery counts as
						low, a backstop under heavy load. null leaves it to the device.
					'';
				};
			};
			onLowBattery = mkOption {
				type = types.enum [ "hibernate" "poweroff" ];
				default = "hibernate";
				description = "What upsmon does once the UPS is on battery and low.";
			};
		};

		outage = {
			cpuProfile = mkOption {
				type = types.nullOr types.str;
				default = "power-saver";
				description = ''
					power-profiles-daemon profile while on battery; the profile that
					was active comes back with the grid. null leaves the CPU alone.
				'';
			};
			spinDown = mkOption {
				type = types.listOf types.str;
				default = [ ];
				example = [ "/dev/disk/by-label/media2.5" ];
				description = "Disks put in standby while on battery: partitions (a filesystem's by-label device) or whole disks, the disk behind each is used.";
			};
			spinDownAfter = mkOption {
				type = types.ints.between 1 20;
				default = 10;
				description = "Minutes a spun-down disk stays idle before it stops again after an access.";
			};
		};
	};

	config = mkIf cfg.ups.enable {
		assertions = [{
			assertion = cfg.ups.onLowBattery != "hibernate" || swap != null;
			message = "modules/system/power: hibernate on low battery needs a swap partition in swapDevices.";
		}];

		boot.resumeDevice = mkIf (cfg.ups.onLowBattery == "hibernate" && swap != null)
			(lib.mkDefault swap.device);

		power.ups = {
			enable = true;
			mode = "standalone";
			ups.ups = {
				inherit (cfg.ups) driver port description;
				directives = cfg.ups.directives ++ [
					# The EcoFlow never answers interrupt transfers; without pollonly
					# every poll first waits out that timeout.
					"pollonly"
					"pollinterval = 2"
				]
				++ optional (cfg.ups.lowBattery.charge != null)
					"override.battery.charge.low = ${toString cfg.ups.lowBattery.charge}"
				++ optional (cfg.ups.lowBattery.runtime != null)
					"override.battery.runtime.low = ${toString cfg.ups.lowBattery.runtime}";
			};
			upsd.listen = [ { address = "127.0.0.1"; } { address = "::1"; } ];
			users.upsmon = { inherit passwordFile; upsmon = "primary"; };
			upsmon.monitor.ups = { user = "upsmon"; type = "primary"; };
			upsmon.settings = {
				NOTIFYCMD = toString notify;
				NOTIFYFLAG = map (event: [ event "SYSLOG+EXEC" ]) [ "ONLINE" "ONBATT" ]
					++ map (event: [ event "SYSLOG" ])
						[ "LOWBATT" "FSD" "SHUTDOWN" "COMMOK" "COMMBAD" "NOCOMM" "REPLBATT" ];
				SHUTDOWNCMD = "${systemctl} ${cfg.ups.onLowBattery}";
				# Keep monitoring after the shutdown command: a hibernate returns.
				SHUTDOWNEXIT = "no";
				# The flag asks the UPS to cut power at halt. The EcoFlow ignores
				# that, and a stale flag would outlive a hibernate.
				POWERDOWNFLAG = null;
			};
		};

		# nutmon may flip the outage target and nothing else.
		security.polkit.extraConfig = ''
			polkit.addRule(function(action, subject) {
				if (action.id == "org.freedesktop.systemd1.manage-units" &&
				    action.lookup("unit") == "power-outage.target" &&
				    subject.user == "nutmon") {
					return polkit.Result.YES;
				}
			});
		'';

		# Nothing wants the target; upsmon starts and stops it.
		systemd.targets.power-outage.description = "Running on the UPS battery";

		systemd.tmpfiles.rules = [
			"d ${stateDir} 0755 root root -"
			"f ${stateDir}/source 0644 root root - grid"
		];

		services.power-profiles-daemon.enable =
			mkIf (cfg.outage.cpuProfile != null) (lib.mkDefault true);

		systemd.services = {
			# upsd and upsmon read the password as a credential at start, so it
			# has to exist before either; a fresh one every boot, never on disk.
			nut-password = {
				description = "Generate the loopback-only NUT password";
				before = [ "upsd.service" "upsmon.service" ];
				requiredBy = [ "upsd.service" "upsmon.service" ];
				unitConfig.ConditionPathExists = "!${passwordFile}";
				serviceConfig = {
					Type = "oneshot";
					ExecStart = pkgs.writeShellScript "nut-password" ''
						# 0755: upsmon's unprivileged child re-reads /run/nut/upsmon.conf on
						# reload (it does one after every resume), so it must traverse here.
						install -d -m 0755 ${dirOf passwordFile}
						umask 077
						${pkgs.coreutils}/bin/head -c 24 /dev/urandom \
							| ${pkgs.coreutils}/bin/base64 > ${passwordFile}
					'';
				};
			};
		}
		// lever "state" "Publish the power source to user sessions" {
			start = "echo battery > ${stateDir}/source";
			stop = "echo grid > ${stateDir}/source";
		}
		// optionalAttrs (cfg.outage.cpuProfile != null)
			(lever "cpu" "CPU power profile for the battery" {
				start = ''
					${powerprofilesctl} get > ${stateDir}/cpu-profile
					${powerprofilesctl} set ${cfg.outage.cpuProfile}
				'';
				stop = ''
					${powerprofilesctl} set "$(cat ${stateDir}/cpu-profile 2>/dev/null || echo balanced)"
				'';
			})
		// optionalAttrs (cfg.outage.spinDown != [ ])
			(lever "disks" "Spin down the media disks on battery" {
				# -S n: standby after n * 5 s idle (n <= 240); -y: stop now.
				start = forEachDisk "${hdparm} -S ${toString (cfg.outage.spinDownAfter * 12)} -y \"$disk\" || true";
				stop = forEachDisk "${hdparm} -S 0 \"$disk\" || true";
			});
	};
}
