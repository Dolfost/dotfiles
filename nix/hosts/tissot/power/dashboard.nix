# What is left of the web dashboard. That was OliveTin, as
# https://dash.<tailnet>; the name now opens Elamon's own page (./elamon.nix,
# ../tailscale), which has the same state and the same buttons, and is what
# a notification opens when tapped (the Click header in ./notify.nix and
# modules/system/power). OliveTin is gone; two things it had stay here, for
# Elamon to use:
#
# aorus's state. aorus.yaml is written every 10 s and after every command
# from what aorus says about itself over ssh (through one connection kept
# open, aorus-link, so aorus does not log a login each time). That ssh goes as the
# power-remote user there (modules/system/power, outage.remote): a forced
# command with four words, status | hold | release | hibernate. The key is
# made here on first boot and its public half is facts.hosts.tissot.remote_key.
# It is still the user olivetin's, in /var/lib/olivetin: aorus knows that
# key, and a new name would be a new key to let in there.
#
# What may be done to the station. nutflow runs only what controlAllow
# lists (./elamon.nix gives its NUT user exactly that). AC 1 (aorus) and
# 12 V (the router, so this very page) are left out on purpose: a stray tap
# would cut what it runs on.
{ pkgs, lib, ... }:

let
	facts = import ../../../facts.nix;
	stateDir = "/run/ups-state";
	keyDir = "/var/lib/olivetin";
	key = "${keyDir}/id_ed25519";
	mux = "${keyDir}/aorus.mux";
	sshTo = extra: lib.concatStringsSep " " ([
		"${pkgs.openssh}/bin/ssh" "-i ${key}" "-o BatchMode=yes" "-o ConnectTimeout=3"
		"-o StrictHostKeyChecking=accept-new" "-o UserKnownHostsFile=${keyDir}/known_hosts"
		# Through aorus-link's connection while there is one, else its own.
		"-o ControlPath=${mux}"
	] ++ extra ++ [ "power-remote@${facts.hosts.aorus.lan_ipv4}" ]);
	ssh = sshTo [ ];
	path = lib.makeBinPath (with pkgs; [ coreutils gnused openssh ]);
	# aorus-remote [status | hold | release | hibernate]: run it there, print
	# the answer, and keep what aorus says about itself for Elamon (one list
	# with one mapping, written in a single printf, so it is never read half).
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
	# What nutflow lets be done: exactly what the switches and settings in
	# Elamon do.
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
in
{
	# For ./elamon.nix, whose aorus buttons run it.
	_module.args.dashboardScripts = { inherit aorus-remote; };

	systemd.tmpfiles.rules = [ "d ${stateDir} 0755 olivetin olivetin -" ];

	services.nutflow.settings.control.allow = controlAllow;

	# Whose the key and the ssh to aorus are (OliveTin's module made this user).
	users.users.olivetin = { isSystemUser = true; group = "olivetin"; };
	users.groups.olivetin = { };

	systemd.services = {
		olivetin-key = {
			description = "The ssh identity for aorus (power-remote there)";
			wantedBy = [ "multi-user.target" ];
			before = [ "aorus-state.service" ];
			unitConfig.ConditionPathExists = "!${key}";
			serviceConfig = {
				Type = "oneshot";
				User = "olivetin";
				Group = "olivetin";
				StateDirectory = "olivetin";
				ExecStart = "${pkgs.openssh}/bin/ssh-keygen -q -t ed25519 -N \"\" -C olivetin@tissot -f ${key}";
			};
		};
		# The one ssh connection to aorus the others go through: it does nothing
		# itself, ends within 10 s of aorus going quiet and is tried again every 10.
		aorus-link = {
			description = "A connection to aorus to ask through";
			wantedBy = [ "multi-user.target" ];
			after = [ "olivetin-key.service" ];
			unitConfig.StartLimitIntervalSec = 0;
			serviceConfig = {
				User = "olivetin";
				Group = "olivetin";
				StateDirectory = "olivetin";
				ExecStartPre = "${pkgs.coreutils}/bin/rm -f ${mux}";
				ExecStart = sshTo [ "-N" "-o ControlMaster=yes" "-o ServerAliveInterval=5" "-o ServerAliveCountMax=2" ];
				Restart = "always";
				RestartSec = 10;
			};
		};
		aorus-state = {
			description = "aorus's state for Elamon";
			serviceConfig = { Type = "oneshot"; User = "olivetin"; Group = "olivetin"; ExecStart = "${aorus-remote} status"; };
		};
	};
	systemd.timers.aorus-state = {
		description = "aorus-state every 10 s";
		wantedBy = [ "timers.target" ];
		timerConfig = { OnBootSec = "20s"; OnUnitActiveSec = "10s"; AccuracySec = "1s"; };
	};
}
