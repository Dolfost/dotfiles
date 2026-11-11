# upsmon as a pure notifier for the daemon in ./default.nix: what the
# EcoFlow and the grid do becomes a push on ntfy's "ups" topic (services/
# ntfy.nix), worded with the numbers that matter at that moment. MINSUPPLIES
# 0 means it never shuts anything down; aorus has its own upsmon for that.
# The token was made once with `ntfy token add` and lives in sops.
#
# A link that merely flaps (the daemon restarting on a rebuild, a Bluetooth
# reconnect) stays in the journal: only NOCOMM, upsmon's "still gone after
# NOCOMMWARNTIME", is pushed, and the next COMMOK only when it follows one.
#
# The phone also wakes aorus, which hibernates a few minutes into an outage
# (modules/system/power, outage.hibernateAfterLock): "grid back" leaves a flag
# that starts a ten-minute countdown ending in a Wake-on-LAN packet, "grid
# lost" removes the flag and the countdown finds nothing to do. Anything to
# do by hand is on the dashboard (./dashboard.nix), which a tap on any of
# these messages opens.
{ config, pkgs, ... }:

let
	facts = import ../../../facts.nix;
	nocommWarnTime = 300;
	wakeAfter = 600;
	flagDir = "/run/ups-notify";
	gridBack = "${flagDir}/grid-back";
	tokenFile = config.sops.secrets."ntfy/token".path;
	dashboard = "https://dash.${facts.ts_network}";
	upsNotify = pkgs.writeShellScript "ups-notify" ''
		PATH=${pkgs.lib.makeBinPath [ pkgs.nut pkgs.curl pkgs.coreutils ]}
		marker=/tmp/ups-notify-nocomm
		# What the daemon knows right now, when it can be asked.
		var() { upsc ups@localhost "$1" 2>/dev/null; }
		charge=$(var battery.charge); runtime=$(var battery.runtime)
		load=$(var ups.realpower); input=$(var input.realpower)
		left=""
		if [ -n "$runtime" ]; then
			left=$(printf '%dh %02dm' $((runtime / 3600)) $((runtime % 3600 / 60)))
		fi
		case "$NOTIFYTYPE" in
			ONBATT)
				rm -f ${gridBack}
				title="Grid lost"; prio=high; tags=electric_plug
				body="Running on the EcoFlow: ''${charge:-?} %, about ''${left:-?} left, ''${load:-?} W out" ;;
			ONLINE)
				touch ${gridBack}
				title="Grid back"; prio=default; tags=white_check_mark
				body="EcoFlow at ''${charge:-?} %, charging from the grid''${input:+ at $input W}; aorus wakes in ${toString (wakeAfter / 60)} min" ;;
			LOWBATT)
				title="Battery low"; prio=urgent; tags=battery
				body="EcoFlow at ''${charge:-?} %, about ''${left:-?} left; aorus hibernates now" ;;
			NOCOMM)
				title="EcoFlow unreachable"; prio=high; tags=warning
				body="No Bluetooth link from tissot for ${toString nocommWarnTime} s"
				touch "$marker" ;;
			COMMOK)
				[ -e "$marker" ] || exit 0
				rm -f "$marker"
				title="EcoFlow back"; prio=low; tags=link
				body="Bluetooth link restored, EcoFlow at ''${charge:-?} %" ;;
			REPLBATT)
				title="Battery needs replacing"; prio=high; tags=battery
				body="$*" ;;
			*) exit 0 ;;
		esac
		exec curl -fsS -o /dev/null \
			-H "Authorization: Bearer $(cat ${tokenFile})" \
			-H "Title: $title" -H "Priority: $prio" -H "Tags: $tags" -H "Click: ${dashboard}" \
			-d "$body" http://127.0.0.1:2586/ups
	'';
in
{
	sops.secrets."ntfy/token" = { owner = "nutmon"; };

	# The notifier's flags (it runs as nutmon) and the wake-up they trigger.
	systemd.tmpfiles.rules = [ "d ${flagDir} 0755 nutmon nutmon -" ];
	systemd.paths.wake-aorus = {
		description = "The grid is back: wake aorus after a while";
		wantedBy = [ "multi-user.target" ];
		pathConfig.PathExists = gridBack;
	};
	systemd.services.wake-aorus = {
		description = "Wake aorus ${toString (wakeAfter / 60)} min after the grid came back";
		serviceConfig = {
			Type = "oneshot";
			ExecStart = pkgs.writeShellScript "wake-aorus" ''
				${pkgs.coreutils}/bin/sleep ${toString wakeAfter}
				# Still on the grid, nothing cancelled it: wake the box.
				[ -e ${gridBack} ] || exit 0
				${pkgs.coreutils}/bin/rm -f ${gridBack}
				${pkgs.nut}/bin/upsc ups@localhost ups.status 2>/dev/null | ${pkgs.gnugrep}/bin/grep -q OL || exit 0
				exec ${pkgs.wakeonlan}/bin/wakeonlan ${facts.hosts.aorus.mac}
			'';
		};
	};

	power.ups = {
		enable = true;
		mode = "netclient";
		upsmon = {
			monitor.ups = {
				system = "ups@localhost";
				user = facts.hosts.tissot.nut.user;
				passwordFile = toString (pkgs.writeText "ups-password" facts.hosts.tissot.nut.password);
				type = "secondary";
			};
			settings = {
				MINSUPPLIES = 0;
				SHUTDOWNCMD = "${pkgs.coreutils}/bin/true";
				NOCOMMWARNTIME = nocommWarnTime;
				NOTIFYCMD = toString upsNotify;
				NOTIFYFLAG = map (event: [ event "SYSLOG+EXEC" ])
					[ "ONLINE" "ONBATT" "LOWBATT" "NOCOMM" "COMMOK" "REPLBATT" ]
					++ [ [ "COMMBAD" "SYSLOG" ] ];
			};
		};
	};
}
