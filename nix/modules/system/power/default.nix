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
# What the outage messages (outage.notify) and the phone's dashboard reach:
# outage.remote lists the ssh keys allowed in as the power-remote user, whose
# forced command knows status | hold | release | hibernate (the dashboard,
# hosts/tissot/power/dashboard.nix, is the only such key). hold and release
# are the auto-hibernate switch below, hibernate is now.
#
# upsd listens on loopback only and the upsmon password is generated at
# boot: reads need no login and nothing else listens, so it is not a secret
# worth sops.
#
# With ups.remote set there is no driver and no upsd here at all: upsmon
# watches a NUT server elsewhere (the phone's Bluetooth link to the same
# EcoFlow, see hosts/tissot) and everything else stays the same - upsmon
# logs in as primary there, so OB+LB still runs SHUTDOWNCMD.
#
# outage.hibernateAfterLock puts the machine to sleep during an outage once
# nobody is at it: a watcher under the target polls whether the screen is
# locked (hyprlock running, or no compositor at all) and hibernates after
# that many minutes of it; unlocking resets the count, the grid coming back
# stops the watcher. `power-outage hibernate off` holds it for this boot (a
# flag in /run/power), and any systemd sleep inhibitor (systemd-inhibit
# --what=sleep, a running backup) holds it too; low battery ignores both.
# The session locks sooner on battery (modules/user/power, outage.lockTimeout).
# Waking up again is someone else's job: the phone sends Wake-on-LAN ten
# minutes after the grid is back (hosts/tissot/power).
{ config, lib, pkgs, ... }:

let
	cfg = config.dotfiles.power;
	inherit (lib) mkOption mkEnableOption types mkIf optional optionalAttrs;

	stateDir = "/run/power";
	noHibernate = "${stateDir}/no-hibernate";
	upsTarget = if remote == null then "ups@localhost" else remote.system;
	# A line on the machine's ntfy topic (outage.notify), with the UPS's
	# numbers of the moment: power-notify TITLE PRIORITY TAGS BODY.
	notifyCfg = cfg.outage.notify;
	tokenFile = if notifyCfg == null then "/dev/null" else notifyCfg.tokenFile;
	# power-notify TITLE PRIORITY TAGS BODY; a tap opens notify.click.
	power-notify = pkgs.writeShellScript "power-notify" ''
		${lib.optionalString (notifyCfg == null) "exit 0"}
		exec ${pkgs.curl}/bin/curl -fsS -m 10 -o /dev/null \
			-H "Authorization: Bearer $(cat ${tokenFile})" \
			-H "Title: $1" -H "Priority: $2" -H "Tags: $3" -d "$4" \
			${lib.optionalString (notifyCfg != null && notifyCfg.click != null) ''-H "Click: ${notifyCfg.click}"''} \
			${if notifyCfg == null then "http://localhost" else "${notifyCfg.url}/${notifyCfg.topic}"} || true
	'';
	upsNumbers = ''
		charge=$(${pkgs.nut}/bin/upsc ${upsTarget} battery.charge 2>/dev/null)
		runtime=$(${pkgs.nut}/bin/upsc ${upsTarget} battery.runtime 2>/dev/null)
		left=""; [ -n "$runtime" ] && left=$(printf '%dh %02dm' $((runtime / 3600)) $((runtime % 3600 / 60)))
	'';
	# What ends an outage here: say so, then do it. Used by the lock watcher
	# (locked), by upsmon's low-battery SHUTDOWNCMD (low) and by power-remote
	# (now). --no-block: the caller's ssh session or unit is done before the
	# sleep starts.
	hibernate-now = pkgs.writeShellScript "power-hibernate-now" ''
		${upsNumbers}
		case "$1" in
			low) ${power-notify} "${config.networking.hostName} ${cfg.ups.onLowBattery}s" urgent battery \
				"Low battery: EcoFlow at ''${charge:-?} %, about ''${left:-?} left" ;;
			now) ${power-notify} "${config.networking.hostName} ${cfg.ups.onLowBattery}s" high zzz \
				"Asked to; EcoFlow at ''${charge:-?} %, about ''${left:-?} left" ;;
			locked) ${power-notify} "${config.networking.hostName} ${cfg.ups.onLowBattery}s" high zzz \
				"Screen locked for ${toString (cfg.outage.hibernateAfterLock or 0)} min on the UPS battery: EcoFlow at ''${charge:-?} %, about ''${left:-?} left" ;;
		esac
		echo "${config.networking.hostName} ${cfg.ups.onLowBattery}s"
		exec ${systemctl} ${cfg.ups.onLowBattery} --no-block
	'';
	# The switch for the countdown below, for the wheel group.
	power-outage = pkgs.writeShellScriptBin "power-outage" ''
		case "$1 $2" in
			"hibernate off") touch ${noHibernate} && echo "auto-hibernate off until reboot (low battery still hibernates)" ;;
			"hibernate on") rm -f ${noHibernate} && echo "auto-hibernate on" ;;
			"hibernate status"|"status ")
				echo "source: $(cat ${stateDir}/source 2>/dev/null || echo grid)"
				[ -e ${noHibernate} ] && echo "auto-hibernate: held (power-outage hibernate on)" || echo "auto-hibernate: on" ;;
			*) echo "usage: power-outage hibernate off|on|status" >&2; exit 1 ;;
		esac
	'';
	# The forced command of the power-remote user (outage.remote): the word is
	# the ssh command. status is readable by anyone; the switch and the
	# hibernate go through the two sudo rules below.
	sudo = "/run/wrappers/bin/sudo";
	power-remote = pkgs.writeShellScript "power-remote" ''
		case "''${SSH_ORIGINAL_COMMAND:-status}" in
			status)
				echo "source: $(cat ${stateDir}/source 2>/dev/null || echo grid)"
				[ -e ${noHibernate} ] && echo "auto-hibernate: held" || echo "auto-hibernate: on" ;;
			hold) exec ${sudo} ${power-outage}/bin/power-outage hibernate off ;;
			release) exec ${sudo} ${power-outage}/bin/power-outage hibernate on ;;
			hibernate) exec ${sudo} ${hibernate-now} now ;;
			*) echo "power-remote: status | hold | release | hibernate" >&2; exit 1 ;;
		esac
	'';
	remote = cfg.ups.remote;
	passwordFile = if remote == null
		then "/run/nut/password"
		else toString (pkgs.writeText "nut-password" remote.password);
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

	upsmonSettings = {
		NOTIFYCMD = toString notify;
		NOTIFYFLAG = map (event: [ event "SYSLOG+EXEC" ]) [ "ONLINE" "ONBATT" ]
			++ map (event: [ event "SYSLOG" ])
				[ "LOWBATT" "FSD" "SHUTDOWN" "COMMOK" "COMMBAD" "NOCOMM" "REPLBATT" ];
		SHUTDOWNCMD = "${hibernate-now} low";
		# Keep monitoring after the shutdown command: a hibernate returns.
		SHUTDOWNEXIT = "no";
		# The flag asks the UPS to cut power at halt. The EcoFlow ignores
		# that, and a stale flag would outlive a hibernate.
		POWERDOWNFLAG = null;
	};

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
			remote = mkOption {
				type = types.nullOr (types.submodule {
					options = {
						system = mkOption {
							type = types.str;
							example = "ups@192.168.0.248";
							description = "The UPS on another NUT server, as upsmon names it.";
						};
						user = mkOption { type = types.str; description = "Login there."; };
						password = mkOption { type = types.str; description = "Its password (a NUT login gates nothing worth sops)."; };
					};
				});
				default = null;
				description = ''
					Watch a NUT server elsewhere instead of a USB UPS here: no driver,
					no upsd, the driver/port/directives/lowBattery options are ignored
					(the thresholds are that server's).
				'';
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
			hibernateAfterLock = mkOption {
				type = types.nullOr types.ints.positive;
				default = null;
				example = 2;
				description = ''
					Minutes the screen has been locked, on the UPS battery, before the
					machine hibernates (null: only at low battery). Unlocking resets
					the count and the grid coming back ends it; `power-outage
					hibernate off` and systemd sleep inhibitors hold it.
				'';
			};
			notify = mkOption {
				type = types.nullOr (types.submodule {
					options = {
						url = mkOption { type = types.str; example = "http://192.168.0.248:2586"; description = "The ntfy server."; };
						topic = mkOption { type = types.str; example = "aorus"; description = "The topic for this machine's own outage notices."; };
						tokenFile = mkOption { type = types.str; description = "A file with an ntfy token allowed to publish there."; };
						click = mkOption {
							type = types.nullOr types.str;
							default = null;
							example = "https://dash.example.ts.net";
							description = "What a tap on such a notice opens (the dashboard).";
						};
					};
				});
				default = null;
				description = "Where to say that the machine hibernates, and that it is back (null: nowhere).";
			};
			remote = mkOption {
				type = types.listOf types.str;
				default = [ ];
				example = [ "ssh-ed25519 AAAA... olivetin@tissot" ];
				description = ''
					ssh public keys let in as the power-remote user, whose only command
					is `status | hold | release | hibernate`: the auto-hibernate switch
					and a hibernate now, for the phone's dashboard.
				'';
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

		power.ups = if remote != null then {
			enable = true;
			mode = "netclient";
			upsmon.monitor.ups = {
				inherit (remote) system user;
				inherit passwordFile;
				type = "primary";
			};
			upsmon.settings = upsmonSettings;
		} else {
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
			upsmon.settings = upsmonSettings;
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
			"d ${stateDir} 0775 root wheel -"
			"f ${stateDir}/source 0644 root root - grid"
		];
		environment.systemPackages = [ power-outage ];
		# Back from a hibernate (either kind): say so, with the grid's state,
		# and a little later rewrite the source file as it is, so the session's
		# path unit fires and re-applies the levers the compositor undid on
		# resume (the monitors' battery refresh rate) - modules/user/power.
		powerManagement.resumeCommands = ''
			${power-notify} "${config.networking.hostName} is back" default sunrise \
				"Resumed; power source: $(${pkgs.coreutils}/bin/cat ${stateDir}/source 2>/dev/null || echo grid)"
			${pkgs.systemd}/bin/systemd-run --quiet --on-active=8 --unit=power-resume-reapply \
				${pkgs.writeShellScript "power-resume-reapply" ''
					src=$(cat ${stateDir}/source 2>/dev/null || echo grid)
					echo "$src" > ${stateDir}/source
				''}
		'';

		services.power-profiles-daemon.enable =
			mkIf (cfg.outage.cpuProfile != null) (lib.mkDefault true);

		# The remote's door: a system user that can only run power-remote, and
		# sudo for exactly the two things in it that write.
		users.users.power-remote = mkIf (cfg.outage.remote != [ ]) {
			isSystemUser = true;
			group = "power-remote";
			shell = pkgs.bash; # sshd runs the forced command through it
			openssh.authorizedKeys.keys =
				map (key: "restrict,command=\"${power-remote}\" ${key}") cfg.outage.remote;
		};
		users.groups.power-remote = mkIf (cfg.outage.remote != [ ]) { };
		security.sudo.extraRules = mkIf (cfg.outage.remote != [ ]) [{
			users = [ "power-remote" ];
			commands = map (command: { inherit command; options = [ "NOPASSWD" ]; }) [
				"${power-outage}/bin/power-outage hibernate off"
				"${power-outage}/bin/power-outage hibernate on"
				"${hibernate-now} now"
			];
		}];

		systemd.services = {
			# upsd and upsmon read the password as a credential at start, so it
			# has to exist before either; a fresh one every boot, never on disk.
			nut-password = mkIf (remote == null) {
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
		// optionalAttrs (cfg.outage.hibernateAfterLock != null) {
			power-outage-hibernate = {
				description = "Hibernate ${toString cfg.outage.hibernateAfterLock} min after the screen locks on the UPS battery";
				partOf = [ "power-outage.target" ];
				wantedBy = [ "power-outage.target" ];
				# Stopping the target (the grid is back) ends the watch. The switch
				# is read every tick, so a release re-arms it; the sleep inhibitors
				# are systemctl's own business (a refused hibernate waits 10 min).
				serviceConfig.ExecStart = pkgs.writeShellScript "power-outage-hibernate" ''
					PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.procps ]}
					# Locked: hyprlock is up, or there is no compositor to lock at all.
					# NixOS wraps both, so the process names are .hyprlock-wrapped and
					# .Hyprland-wrapped (truncated to 15 characters): a prefix match.
					locked() {
						pgrep -u ${config.dotfiles.user} '^\.?hyprlock' >/dev/null && return 0
						pgrep -u ${config.dotfiles.user} '^\.?Hyprland' >/dev/null || return 0
						return 1
					}
					after=${toString (cfg.outage.hibernateAfterLock * 60)}
					since=""
					while :; do
						if [ -e ${noHibernate} ] || ! locked; then
							since=""
						else
							now=$(date +%s); [ -n "$since" ] || since=$now
							if [ $((now - since)) -ge "$after" ]; then
								since=""
								# The loop outlives the hibernate: back from it and still on
								# battery and locked, the count starts over.
								if ${hibernate-now} locked; then sleep 60; else sleep 600; fi
								continue
							fi
						fi
						sleep 5
					done
				'';
			};
		}
		// optionalAttrs (cfg.outage.spinDown != [ ])
			(lever "disks" "Spin down the media disks on battery" {
				# -S n: standby after n * 5 s idle (n <= 240); -y: stop now.
				start = forEachDisk "${hdparm} -S ${toString (cfg.outage.spinDownAfter * 12)} -y \"$disk\" || true";
				stop = forEachDisk "${hdparm} -S 0 \"$disk\" || true";
			});
	};
}
