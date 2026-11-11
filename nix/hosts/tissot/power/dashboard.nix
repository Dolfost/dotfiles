# The dashboard: OliveTin (docs.olivetin.app) with the EcoFlow's state and
# the few things there are to do about an outage, as https://dash.<tailnet>
# (a Tailscale service like ntfy, ../tailscale; the identity header it adds
# names the viewer). ntfy keeps the notifications; this is where the buttons
# went, and what a notification opens when tapped (the Click header in
# ./notify.nix and modules/system/power).
#
# State is two entity files OliveTin watches: ups.yaml, written every 10 s
# from upsc, and aorus.yaml, written once a minute and after every command
# from what aorus says about itself over ssh. That ssh goes as the
# power-remote user there (modules/system/power, outage.remote): a forced
# command with four words, status | hold | release | hibernate. The key is
# made here on first boot and its public half is facts.hosts.tissot.remote_key.
# Waking aorus is a Wake-on-LAN packet, the same as after an outage (notify.nix).
{ pkgs, lib, ... }:

let
	facts = import ../../../facts.nix;
	stateDir = "/run/ups-state";
	outlets = lib.range 1 9; # outlet.N as the daemon numbers them (AC 1, AC 2, USB, 12 V)
	keyDir = "/var/lib/olivetin";
	key = "${keyDir}/id_ed25519";
	ssh = lib.concatStringsSep " " [
		"${pkgs.openssh}/bin/ssh" "-i ${key}" "-o BatchMode=yes" "-o ConnectTimeout=3"
		"-o StrictHostKeyChecking=accept-new" "-o UserKnownHostsFile=${keyDir}/known_hosts"
		"power-remote@${facts.hosts.aorus.lan_ipv4}"
	];
	path = lib.makeBinPath (with pkgs; [ coreutils gnused nut openssh wakeonlan ]);
	# Each entity file is one list with one mapping, written in a single
	# printf: OliveTin re-reads it on every change and should never see half.
	ups-state = pkgs.writeShellScript "ups-state" ''
		PATH=${path}
		vars=$(upsc ups@localhost 2>/dev/null) || vars=""
		raw() { printf '%s\n' "$vars" | sed -n "s/^$1: //p"; }
		v() { x=$(raw "$1"); echo "''${x:-?}"; }
		status=$(raw ups.status)
		case "$status" in
			"") state="unreachable (no Bluetooth link)" ;;
			*OB*) state="on battery" ;;
			*OL*) state="on the grid" ;;
			*) state="$status" ;;
		esac
		case "$status" in *DISCHRG*) state="$state, discharging" ;; *CHRG*) state="$state, charging" ;; esac
		case "$status" in *LB*) state="LOW BATTERY, $state" ;; esac
		runtime=$(raw battery.runtime); left="?"
		[ -n "$runtime" ] && left=$(printf '%dh %02dm' $((runtime / 3600)) $((runtime % 3600 / 60)))
		content=$(
			echo "- name: EcoFlow"
			echo "  state: \"$state\""
			echo "  charge: \"$(v battery.charge)\""
			echo "  left: \"$left\""
			echo "  input: \"$(v input.realpower)\""
			echo "  output: \"$(v ups.realpower)\""
			echo "  load: \"$(v ups.load)\""
			echo "  temperature: \"$(v battery.temperature)\""
			echo "  checked: \"$(date +%H:%M:%S)\""
			# oN: the outlet's watts or "off", oNn: its name.
			for n in ${toString outlets}; do
				if [ "$(raw outlet.$n.status)" = off ]; then w=off; else w="$(v outlet.$n.realpower) W"; fi
				echo "  o''${n}n: \"$(raw outlet.$n.desc)\""
				echo "  o$n: \"$w\""
			done
		)
		printf '%s\n' "$content" > ${stateDir}/ups.yaml
	'';
	# aorus-remote [status | hold | release | hibernate]: run it there, print
	# the answer, and keep what aorus says about itself for the dashboard.
	aorus-remote = pkgs.writeShellScript "aorus-remote" ''
		PATH=${path}
		word=''${1:-status}; rc=0
		[ "$word" = status ] || ${ssh} "$word" || rc=$?
		if [ "$word" = hibernate ] && [ $rc = 0 ]; then
			state=hibernating; reply=""
		elif reply=$(${ssh} status 2>/dev/null); then
			state=up
		else
			state="down (hibernated or off)"; reply=""
		fi
		source=$(printf '%s\n' "$reply" | sed -n 's/^source: //p')
		hib=$(printf '%s\n' "$reply" | sed -n 's/^auto-hibernate: //p')
		printf -- '- name: aorus\n  state: "%s"\n  source: "%s"\n  auto_hibernate: "%s"\n  checked: "%s"\n' \
			"$state" "''${source:--}" "''${hib:--}" "$(date +%H:%M:%S)" > ${stateDir}/aorus.yaml
		[ "$word" != status ] || echo "aorus is $state''${reply:+; $(printf '%s' "$reply" | tr '\n' ' ')}"
		exit $rc
	'';
	every = seconds: unit: {
		description = "${unit} every ${toString seconds} s";
		wantedBy = [ "timers.target" ];
		timerConfig = {
			OnBootSec = "20s";
			OnUnitActiveSec = "${toString seconds}s";
			AccuracySec = "1s";
		};
	};
	asOlivetin = exe: {
		serviceConfig = { Type = "oneshot"; User = "olivetin"; Group = "olivetin"; ExecStart = exe; };
	};
	icon = entity: "&#${toString entity};";
	# A tile on a dashboard: the value large, what it is under it.
	tile = label: value: { type = "display"; title = "<strong>${value}</strong><br /><small>${label}</small>"; };
in
{
	systemd.tmpfiles.rules = [ "d ${stateDir} 0755 olivetin olivetin -" ];

	systemd.services = {
		olivetin-key = {
			description = "The dashboard's ssh identity for aorus (power-remote there)";
			wantedBy = [ "multi-user.target" ];
			before = [ "olivetin.service" "aorus-state.service" ];
			unitConfig.ConditionPathExists = "!${key}";
			serviceConfig = {
				Type = "oneshot";
				User = "olivetin";
				Group = "olivetin";
				StateDirectory = "olivetin";
				ExecStart = "${pkgs.openssh}/bin/ssh-keygen -q -t ed25519 -N \"\" -C olivetin@tissot -f ${key}";
			};
		};
		ups-state = asOlivetin ups-state // { description = "The EcoFlow's state for the dashboard"; };
		aorus-state = asOlivetin "${aorus-remote} status" // { description = "aorus's state for the dashboard"; };
		olivetin = {
			# The key first, and both files written once, so it starts with state.
			after = [ "olivetin-key.service" "ups-state.service" "aorus-state.service" ];
			wants = [ "olivetin-key.service" "ups-state.service" "aorus-state.service" ];
			serviceConfig.StateDirectory = "olivetin"; # the key and known_hosts
		};
	};
	systemd.timers = {
		ups-state = every 10 "ups-state";
		aorus-state = every 60 "aorus-state";
	};

	services.olivetin = {
		enable = true;
		settings = {
			ListenAddressSingleHTTPFrontend = "127.0.0.1:1337"; # tailscale serve only (../tailscale)
			pageTitle = "Dashboard";
			showFooter = false;
			showNewVersions = false;
			defaultOnClick = "execution-dialog"; # every button shows what it did
			authHttpHeaderUsername = "Tailscale-User-Login";
			entities = [
				{ file = "${stateDir}/ups.yaml"; name = "ups"; icon = icon 128267; } # battery
				{ file = "${stateDir}/aorus.yaml"; name = "aorus"; icon = icon 128421; } # desktop computer
			];
			# hidden: off the built-in "Actions" list; the two tabs below place
			# each by title.
			actions = map (a: a // { hidden = true; }) [
				{
					title = "Wake"; id = "wake"; icon = icon 9889; timeout = 10;
					shell = "${pkgs.wakeonlan}/bin/wakeonlan ${facts.hosts.aorus.mac} >/dev/null && echo 'Wake-on-LAN sent to aorus'";
				}
				{
					title = "Keep awake"; id = "hold"; icon = icon 9208; timeout = 15;
					shell = "${aorus-remote} hold";
				}
				{
					title = "Allow hibernate"; id = "release"; icon = icon 9654; timeout = 15;
					shell = "${aorus-remote} release";
				}
				{
					title = "Hibernate now"; id = "hibernate"; icon = icon 128164; timeout = 15;
					shell = "${aorus-remote} hibernate";
					arguments = [ { name = "sure"; title = "Hibernate aorus now"; type = "confirmation"; } ];
				}
				{
					title = "Refresh"; id = "refresh"; icon = icon 128260; timeout = 15;
					shell = "${ups-state} && ${aorus-remote} status";
				}
				{
					title = "Every variable"; id = "vars"; icon = "logs"; timeout = 10;
					shell = "${pkgs.nut}/bin/upsc ups@localhost";
				}
			];
			dashboards = [
				{
					title = "Dorm Power";
					contents = [
						{
							type = "fieldset"; entity = "ups"; title = "EcoFlow: {{ ups.state }}";
							contents = [
								(tile "charge" "{{ ups.charge }} %")
								(tile "left" "{{ ups.left }}")
								(tile "in" "{{ ups.input }} W")
								(tile "out" "{{ ups.output }} W")
								(tile "of 3000 W" "{{ ups.load }} %")
								(tile "battery" "{{ ups.temperature }} &deg;C")
								(tile "as of" "{{ ups.checked }}")
							];
						}
						{
							type = "fieldset"; entity = "ups"; title = "Outlets";
							contents = map (n: tile "{{ ups.o${toString n}n }}" "{{ ups.o${toString n} }}") outlets;
						}
						{
							type = "fieldset"; title = "EcoFlow";
							contents = [ { title = "Every variable"; } { title = "Refresh"; } ];
						}
					];
				}
				{
					title = "aorus";
					contents = [
						{
							type = "fieldset"; entity = "aorus"; title = "aorus: {{ aorus.state }}";
							contents = [
								(tile "auto-hibernate" "{{ aorus.auto_hibernate }}")
								(tile "power source" "{{ aorus.source }}")
								(tile "as of" "{{ aorus.checked }}")
							];
						}
						{
							type = "fieldset"; title = "aorus";
							contents = [
								{ title = "Wake"; }
								{ title = "Keep awake"; }
								{ title = "Allow hibernate"; }
								{ title = "Hibernate now"; }
								{ title = "Refresh"; }
							];
						}
					];
				}
			];
		};
	};
}
