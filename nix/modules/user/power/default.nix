# The session's half of an outage (host half: ../../system/power). A path
# unit watches /run/power/source: "battery" starts the user
# power-outage.target and every saving under it applies, "grid" stops it and
# each one reverts. The savings are host choices - monitors drop to a lower
# refresh rate (the dGPU's memory clock follows it), panels dim over DDC,
# chosen user units stop, and a second hypridle instance turns the screen
# off fast and can put the machine to sleep after a while. The defaults
# change nothing but the notifications: the machine is a server first and
# stays up for its services.
#
# The user manager lingers (podman), so the target and the units lever live
# independently of any graphical session: a logout mid-outage keeps the
# containers stopped. Only the two levers that need the compositor (display,
# idle) follow graphical-session.target, and power-session re-applies them
# and announces the state whenever a session starts during an outage.
{ osConfig ? { }, config, lib, pkgs, ... }:

let
	cfg = config.dotfiles.power;
	inherit (lib) mkOption types mkIf optional optionalAttrs optionalString;

	ups = "ups@localhost";
	hostLow = osConfig.dotfiles.power.ups.lowBattery.charge or null;
	hostAction = {
		hibernate = "hibernates";
		poweroff = "powers off";
	}.${osConfig.dotfiles.power.ups.onLowBattery or "poweroff"};
	hyprland = config.dotfiles.hyprland.enable or false;
	tools = with pkgs; [ nut libnotify jq ddcutil coreutils gawk ];

	withDisplay = (cfg.outage.refreshRate != null && hyprland) || cfg.outage.brightness != null;
	withIdle = hyprland && (cfg.outage.dpmsTimeout > 0 || cfg.outage.idle.command != null);

	script = name: text: lib.getExe (pkgs.writeShellApplication {
		inherit name text;
		runtimeInputs = tools;
		# hyprctl and systemctl come from the session's PATH
		excludeShellChecks = [ "SC2016" ];
	});

	# Writes "$state" and reads the current charge; shared by the scripts.
	prelude = ''
		state="''${XDG_RUNTIME_DIR:-/tmp}/power"
		mkdir -p "$state"
		charge() { upsc ${ups} battery.charge 2>/dev/null || echo "?"; }
	'';

	# Applies or reverts the display part. The monitor list is read from
	# Hyprland right before the switch and replayed on restore, so a host only
	# names the battery refresh rate; the everyday modes stay in hypr-local.
	display = script "power-outage-display" ''
		${prelude}
		rate=${optionalString (cfg.outage.refreshRate != null && hyprland) (toString cfg.outage.refreshRate)}
		brightness=${optionalString (cfg.outage.brightness != null) (toString cfg.outage.brightness)}

		# $1: jq expression for the mode string of a hyprctl monitors entry.
		apply_modes() {
			jq -r '.[] | select(.disabled | not)
				| [.name, '"$1"', "\(.x)x\(.y)", .scale, .transform, .mirrorOf] | @tsv' \
				"$state/monitors.json" |
			while IFS=$'\t' read -r name mode pos scale transform mirror; do
				extra=""
				[ "$mirror" = none ] || extra=", mirror='$mirror'"
				hyprctl eval "hl.monitor({output='$name', mode='$mode', position='$pos', scale=$scale, transform=$transform$extra})" >/dev/null || true
			done
		}

		case "$1" in
		apply)
			if [ -n "$rate" ]; then
				# Keep the first snapshot: a second apply (a new session) would
				# otherwise save the lowered modes and restore to them.
				[ -s "$state/monitors.json" ] ||
					hyprctl monitors -j > "$state/monitors.json" || rm -f "$state/monitors.json"
				[ -s "$state/monitors.json" ] && apply_modes "\"\(.width)x\(.height)@$rate\""
			fi
			if [ -n "$brightness" ] && [ ! -s "$state/brightness" ]; then
				: > "$state/brightness"
				for d in $(ddcutil detect --brief 2>/dev/null | awk '/^Display/ { print $2 }'); do
					cur=$(ddcutil -d "$d" getvcp 10 --brief 2>/dev/null | awk '{ print $4 }')
					[ -n "$cur" ] || continue
					echo "$d $cur" >> "$state/brightness"
					ddcutil -d "$d" setvcp 10 "$brightness" || true
				done
			fi
			;;
		restore)
			if [ -f "$state/monitors.json" ]; then
				apply_modes '"\(.width)x\(.height)@\(.refreshRate | round)"'
				rm -f "$state/monitors.json"
			fi
			if [ -f "$state/brightness" ]; then
				while read -r d cur; do
					ddcutil -d "$d" setvcp 10 "$cur" || true
				done < "$state/brightness"
				rm -f "$state/brightness"
			fi
			;;
		esac
	'';

	# Stops the listed units that are running and remembers which, so the
	# grid brings back exactly those.
	units = script "power-outage-units" ''
		${prelude}
		case "$1" in
		apply)
			: > "$state/stopped"
			for unit in ${lib.escapeShellArgs cfg.outage.stopUnits}; do
				if systemctl --user -q is-active "$unit"; then
					echo "$unit" >> "$state/stopped"
					systemctl --user stop "$unit" || true
				fi
			done
			;;
		restore)
			if [ -f "$state/stopped" ]; then
				while read -r unit; do
					systemctl --user start "$unit" || true
				done < "$state/stopped"
				rm -f "$state/stopped"
			fi
			;;
		esac
	'';

	# Follows /run/power/source: flips the user target and tells the user
	# once per change. `session` is the variant run when a graphical session
	# starts: it re-runs the compositor-bound levers for the new session and
	# always announces an ongoing outage.
	source = script "power-source" ''
		${prelude}
		mode=''${1:-change}
		src=$(cat /run/power/source 2>/dev/null || echo grid)
		last=$(cat "$state/last" 2>/dev/null || echo grid)
		case "$src" in
		battery)
			# Starting an active target re-enqueues its wants, so the levers the
			# last session took down with it (display, idle) come back for this one.
			systemctl --user start power-outage.target
			if [ "$mode" = session ]; then
				notify-send -a power -u critical "Running on the UPS" "Charge at $(charge)%" || true
			elif [ "$last" != battery ]; then
				notify-send -a power -u critical "Grid power lost" "Running on the UPS at $(charge)%" || true
			fi
			;;
		*)
			systemctl --user stop power-outage.target
			rm -f "$state/warned"
			if [ "$mode" != session ] && [ "$last" != grid ]; then
				notify-send -a power "Grid power is back" "UPS at $(charge)%, charging" || true
			fi
			;;
		esac
		echo "$src" > "$state/last"
	'';

	# Once a minute on battery: one critical warning as the charge nears the
	# host's low-battery action. Without a session to show it the warning is
	# retried next minute.
	status = script "power-outage-status" ''
		${prelude}
		charge=$(charge)
		[ "$charge" != "?" ] || exit 0
		if [ "$charge" -le ${toString cfg.warnCharge} ] && [ ! -f "$state/warned" ]; then
			notify-send -a power -u critical "UPS at $charge%" \
				"The machine ${hostAction} at ${toString hostLow}%" \
				&& touch "$state/warned" || true
		fi
	'';

	# One saving = one unit under the target: start applies, stop reverts.
	# Session-bound levers also stop with the graphical session; power-session
	# starts them again for the next one.
	lever = { name, description, exe, session ? false }: {
		"power-outage-${name}" = {
			Unit = {
				Description = description;
				PartOf = [ "power-outage.target" ] ++ optional session "graphical-session.target";
			};
			Service = {
				Type = "oneshot";
				RemainAfterExit = true;
				ExecStart = "${exe} apply";
				ExecStop = "${exe} restore";
			};
			Install.WantedBy = [ "power-outage.target" ];
		};
	};
in
{
	options.dotfiles.power = {
		enable = mkOption {
			type = types.bool;
			default = osConfig.dotfiles.power.ups.enable or false;
			description = "Follow the host's UPS: notifications, and the outage savings below.";
		};

		warnCharge = mkOption {
			type = types.nullOr types.int;
			default = if hostLow == null then null else hostLow + 10;
			defaultText = "the host's lowBattery.charge + 10";
			description = "Charge percent at which a critical notification warns that low battery is near. null disables it.";
		};

		outage = {
			refreshRate = mkOption {
				type = types.nullOr types.int;
				default = null;
				example = 60;
				description = ''
					Refresh rate every enabled monitor switches to on battery;
					resolution, position and scale stay. null keeps the modes.
				'';
			};
			brightness = mkOption {
				type = types.nullOr (types.ints.between 0 100);
				default = null;
				description = "DDC brightness for every external panel on battery; the old values return with the grid.";
			};
			stopUnits = mkOption {
				type = types.listOf types.str;
				default = [ ];
				example = [ "nicotine.service" ];
				description = "User units stopped on battery; those that were running start again with the grid.";
			};
			dpmsTimeout = mkOption {
				type = types.int;
				default = 120;
				description = "Idle seconds before the screen turns off on battery. 0 disables.";
			};
			idle = {
				timeout = mkOption {
					type = types.int;
					default = 1200;
					description = "Idle seconds before idle.command runs on battery.";
				};
				command = mkOption {
					type = types.nullOr types.str;
					default = null;
					example = "systemctl hibernate";
					description = ''
						Run after idle.timeout seconds of idleness on battery. null,
						the default, keeps the machine up for its services.
					'';
				};
			};
		};
	};

	config = mkIf cfg.enable {
		systemd.user.targets.power-outage.Unit.Description = "Running on the UPS battery";

		# From the first user manager on (linger), not from the session.
		systemd.user.paths.power-source = {
			Unit.Description = "Watch the host's power source";
			Path = {
				PathChanged = "/run/power/source";
				Unit = "power-source.service";
			};
			Install.WantedBy = [ "default.target" ];
		};

		systemd.user.services = {
			# Also runs once when the manager comes up, so a boot mid-outage
			# catches up before any login.
			power-source = {
				Unit.Description = "Follow the host's power source";
				Service = { Type = "oneshot"; ExecStart = source; };
				Install.WantedBy = [ "default.target" ];
			};
			power-session = {
				Unit = {
					Description = "Apply the power state to a new graphical session";
					After = [ "graphical-session.target" ];
					PartOf = [ "graphical-session.target" ];
				};
				Service = { Type = "oneshot"; ExecStart = "${source} session"; };
				Install.WantedBy = [ "graphical-session.target" ];
			};
		}
		// optionalAttrs (cfg.warnCharge != null) {
			power-outage-status = {
				Unit.Description = "Warn as the UPS charge nears low battery";
				Service = { Type = "oneshot"; ExecStart = status; };
			};
		}
		// optionalAttrs withDisplay (lever {
			name = "display";
			description = "Lower refresh rate and brightness on battery";
			exe = display;
			session = true;
		})
		// optionalAttrs (cfg.outage.stopUnits != [ ]) (lever {
			name = "units";
			description = "Stop the chosen user units on battery";
			exe = units;
		})
		// optionalAttrs withIdle {
			# A second hypridle alongside the everyday one (hypr/hypridle.conf):
			# alive only while the target is, with its own shorter timeouts.
			power-outage-idle = {
				Unit = {
					Description = "Short idle timeouts on battery";
					PartOf = [ "power-outage.target" "graphical-session.target" ];
				};
				Service.ExecStart =
					"${lib.getExe config.services.hypridle.package} -c %h/.config/hypr-local/hypridle-outage.conf";
				Install.WantedBy = [ "power-outage.target" ];
			};
		};

		systemd.user.timers = optionalAttrs (cfg.warnCharge != null) {
			power-outage-status = {
				Unit = {
					Description = "Warn as the UPS charge nears low battery";
					PartOf = [ "power-outage.target" ];
				};
				Timer = { OnActiveSec = "10s"; OnUnitActiveSec = "60s"; };
				Install.WantedBy = [ "power-outage.target" ];
			};
		};

		xdg.configFile = optionalAttrs withIdle {
			"hypr-local/hypridle-outage.conf".text =
				optionalString (cfg.outage.dpmsTimeout > 0) ''
					listener {
						timeout = ${toString cfg.outage.dpmsTimeout}
						on-timeout = hyprctl dispatch "hl.dsp.dpms({action='disable'})"
						on-resume = hyprctl dispatch "hl.dsp.dpms({action='enable'})"
					}
				''
				+ optionalString (cfg.outage.idle.command != null) ''
					listener {
						timeout = ${toString cfg.outage.idle.timeout}
						on-timeout = ${cfg.outage.idle.command}
					}
				'';
		};
	};
}
