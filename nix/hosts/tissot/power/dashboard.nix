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
#
# The EcoFlow tab switches outlets and changes settings through nutflow's
# control socket (`nutflow ctl`, ./default.nix): OliveTin's user is in the
# nutflow group, which may open it, and nutflow runs only what
# controlAllow lists. Every value is a fixed choice and exec runs without
# a shell. AC 1 (aorus) and 12 V (the router, so this very page) are left
# out on purpose: a stray tap would cut what it runs on.
{ config, pkgs, lib, ... }:

let
	facts = import ../../../facts.nix;
	stateDir = "/run/ups-state";
	outlets = lib.range 1 9; # outlet.N as nutflow numbers them (AC 1, AC 2, USB, 12 V)
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
			# The grid's volts: none on battery, the station measures nothing then.
			echo "  grid: \"$(v input.voltage)\""
			# What the EcoFlow tab changes, as the station reports it now.
			echo "  ac2: \"$(v outlet.2.status)\""
			echo "  usb: \"$(v outlet.3.status)\""
			echo "  beeper: \"$(v ups.beeper.status)\""
			echo "  limit: \"$(v experimental.battery.charge.max)\""
			echo "  minimum: \"$(v experimental.battery.charge.minimum)\""
			echo "  chargew: \"$(v experimental.charger.realpower.max)\""
			echo "  brightness: \"$(v experimental.display.brightness)\""
			echo "  screen: \"$(v experimental.display.timeout)\""
			echo "  ac2off: \"$(v experimental.output.ac2.timeout)\""
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

	# ups-ctl ARGS...: `nutflow ctl ARGS`, which answers once the station has
	# acknowledged, then the tiles again after the station's next report
	# (about a second) so they show the change.
	ups-ctl = pkgs.writeShellScript "ups-ctl" ''
		${lib.getExe config.services.nutflow.package} ctl "$@"; rc=$?
		${pkgs.coreutils}/bin/sleep 2
		${ups-state}
		exit $rc
	'';
	# What nutflow lets the socket do: exactly what the buttons below do.
	controlAllow = [
		"outlet.2.load.*" # AC 2
		"outlet.3.load.*" # every USB port: they share one switch
		"beeper.*"
		"experimental.battery.charge.max"
		"experimental.battery.charge.minimum"
		"experimental.charger.realpower.max"
		"experimental.display.brightness"
		"experimental.display.timeout"
		"experimental.output.ac2.timeout"
	];
	# "<what> on" and "<what> off" for a switch.
	switch = what: id: entity: args: map (state: {
		title = "${what} ${state}"; id = "${id}-${state}"; icon = icon entity; timeout = 15;
		exec = [ "${ups-ctl}" ] ++ args ++ [ state ];
	}) [ "on" "off" ];
	# A button that asks which of the choices ([ value label ] pairs) to set
	# the variable to.
	setting = title: id: entity: variable: choices: {
		inherit title id; icon = icon entity; timeout = 15;
		exec = [ "${ups-ctl}" "set" "ups" variable "{{ .Arguments.value }}" ];
		arguments = [{
			name = "value"; inherit title; rejectNull = true;
			choices = map (c: { value = toString (lib.elemAt c 0); title = lib.elemAt c 1; }) choices;
		}];
	};
	controls =
		switch "AC 2" "ac2" 128268 [ "outlet" "ups" "2" ] # electric plug
		++ switch "USB" "usb" 128241 [ "outlet" "ups" "3" ] # mobile phone
		++ switch "Beeper" "beeper" 128264 [ "beeper" "ups" ] # speaker
		++ [
			(setting "Charge limit" "charge-max" 128267 "experimental.battery.charge.max" [
				[ 80 "80 %, easier on the battery" ] [ 90 "90 %" ] [ 100 "100 %, the longest runtime" ]
			])
			# Below the 20 % at which aorus hibernates (low_battery_percent), or
			# the station would cut AC 1 before aorus is down.
			(setting "Discharge limit" "charge-min" 129707 "experimental.battery.charge.minimum" [
				[ 0 "0 %, all of it" ] [ 5 "5 %" ] [ 10 "10 %" ] [ 15 "15 %" ]
			])
			(setting "Charging power" "charge-watts" 9889 "experimental.charger.realpower.max" [
				[ 300 "300 W, quiet" ] [ 500 "500 W" ] [ 700 "700 W" ] [ 1000 "1000 W" ] [ 1500 "1500 W" ] [ 2400 "2400 W, fastest" ]
			])
			(setting "Screen brightness" "brightness" 128262 "experimental.display.brightness" [
				[ 10 "Dim" ] [ 30 "Low" ] [ 60 "Medium" ] [ 100 "Full" ]
			])
			(setting "Screen timeout" "screen" 128164 "experimental.display.timeout" [
				[ 10 "10 s" ] [ 30 "30 s" ] [ 60 "1 min" ] [ 300 "5 min" ] [ 1800 "30 min" ] [ 0 "Never" ]
			])
			(setting "AC 2 auto-off" "ac2-timeout" 9201 "experimental.output.ac2.timeout" [
				[ 0 "Never" ] [ 30 "After 30 min idle" ] [ 60 "After 1 h idle" ] [ 120 "After 2 h idle" ] [ 240 "After 4 h idle" ] [ 720 "After 12 h idle" ]
			])
		];
in
{
	systemd.tmpfiles.rules = [ "d ${stateDir} 0755 olivetin olivetin -" ];

	# The buttons' way in to nutflow (./default.nix): its socket belongs to
	# the nutflow group, and nutflow does only what controlAllow lists.
	services.nutflow.settings.control.allow = controlAllow;
	users.users.olivetin.extraGroups = [ "nutflow" ];

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
			# hidden: off the built-in "Actions" list; the tabs below place each
			# by title.
			actions = map (a: a // { hidden = true; }) ([
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
			] ++ controls);
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
								(tile "grid" "{{ ups.grid }} V")
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
					title = "EcoFlow";
					contents = [
						{
							type = "fieldset"; entity = "ups"; title = "Now";
							contents = [
								(tile "AC 2" "{{ ups.ac2 }}")
								(tile "USB" "{{ ups.usb }}")
								(tile "beeper" "{{ ups.beeper }}")
								(tile "charge limit" "{{ ups.limit }} %")
								(tile "discharge limit" "{{ ups.minimum }} %")
								(tile "charging power" "{{ ups.chargew }} W")
								(tile "screen brightness" "{{ ups.brightness }} %")
								(tile "screen off after (s, 0 never)" "{{ ups.screen }}")
								(tile "AC 2 off after idle (min, 0 never)" "{{ ups.ac2off }}")
								(tile "as of" "{{ ups.checked }}")
							];
						}
						{
							type = "fieldset"; title = "Outlets";
							contents = map (title: { inherit title; }) [ "AC 2 on" "AC 2 off" "USB on" "USB off" ];
						}
						{
							type = "fieldset"; title = "Battery";
							contents = map (title: { inherit title; }) [ "Charge limit" "Discharge limit" "Charging power" ];
						}
						{
							type = "fieldset"; title = "Station";
							contents = map (title: { inherit title; }) [
								"Beeper on" "Beeper off" "Screen brightness" "Screen timeout" "AC 2 auto-off" "Refresh"
							];
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
