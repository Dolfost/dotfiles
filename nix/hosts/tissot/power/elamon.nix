# Elamon (github:Elaizes/elamon): the phone and the EcoFlow in the Elamon
# app on Android, beside the web dashboard (./dashboard.nix) and with the
# same things to do. elamond is a user service (ours, lingering), on :47823
# for paired phones only: `elamond pair` here prints the QR code.
#
# The EcoFlow is a source it reads from nutflow like any NUT client, and its
# tab comes with elamond: the status, a timeline of the outages, the
# outlets, graphs that reach back (filled from upst's recorder for the time
# before elamond), and the switches. It may switch and set exactly what the
# web dashboard may (nutflow's control.allow there): AC 2, USB, the beeper,
# the charge limits, the charging power and the screen. AC 1 (aorus) and
# 12 V (the router) stay out of reach. It logs in to nutflow as the NUT user
# elamon, whose password is made here on first boot and never leaves the
# phone.
#
# The Dorm tab has what the standard one lacks: aorus (wake, keep awake,
# hibernate; through the web dashboard's own script and ssh identity, as
# olivetin) and a few things for the station. Control lists the phone's
# web pages, and the rest is tissot itself: load, memory, storage, processes.
{ config, inputs, lib, pkgs, dashboardScripts, ... }:

let
	facts = import ../../../facts.nix;
	user = config.dotfiles.user;
	# What phones may run on the station: what the web dashboard may.
	allowed = config.services.nutflow.settings.control.allow;
	split = lib.partition (lib.hasPrefix "experimental.") allowed;
	nutflowPassword = "/var/lib/secrets/nut-elamon"; # root's, for nutflow
	elamonPassword = "/var/lib/elamon/nut.password"; # ours, for elamond
	sudo = "/run/wrappers/bin/sudo";
	aorus = word: [ sudo "-n" "-u" "olivetin" "${dashboardScripts.aorus-remote}" word ];
	button = action: label: icon: { type = "button"; inherit action label icon; };
	page = name: svc: { inherit name; url = "https://${svc}.${facts.ts_network}"; };
in
{
	imports = [ inputs.elamon.nixosModules.default ];

	users.users.${user}.linger = true; # the service runs with nobody logged in

	# The NUT user's password: made once, a copy for each side.
	systemd.services.nut-elamon-password = {
		description = "The password of elamond's NUT user";
		wantedBy = [ "multi-user.target" ];
		requiredBy = [ "nutflow.service" ];
		before = [ "nutflow.service" "user@${toString config.users.users.${user}.uid}.service" ];
		path = [ pkgs.coreutils ];
		serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
		script = ''
			umask 077
			mkdir -p /var/lib/secrets
			test -s ${nutflowPassword} || echo "nut-$(head -c 15 /dev/urandom | base32)" > ${nutflowPassword}
			install -d -o ${user} -g ${user} -m 700 ${dirOf elamonPassword}
			install -o ${user} -g ${user} -m 600 ${nutflowPassword} ${elamonPassword}
		'';
	};
	services.nutflow.users.elamon = {
		passwordFile = nutflowPassword;
		allow = allowed;
	};

	services.elamond = {
		enable = true;
		users = [ user ];
		# Built on the phone: its tests (an HTTP server, curl) would only add minutes.
		package = inputs.elamon.packages.${pkgs.stdenv.hostPlatform.system}.elamond.overrideAttrs { doCheck = false; };
		settings = {
			name = "tissot";
			control = true;
			# 5353 is the host's (avahi there); the app has the address from the QR code.
			mdns = false;

			sources.eco = {
				kind = "nut";
				ups = "ups";
				capacity_wh = 2048;
				recorder = "/run/upst/upst.sock";
				user = "elamon";
				password_file = elamonPassword;
				commands = split.wrong;
				settings = split.right;
			};

			links = {
				dash = page "Dashboard" "dash";
				ntfy = page "ntfy" "ntfy";
				pihole = page "Pi-hole" "pihole";
			};

			actions = {
				aorus-wake = {
					name = "Wake aorus"; icon = "bolt"; confirm = false; timeout = 10;
					command = [ "${pkgs.wakeonlan}/bin/wakeonlan" facts.hosts.aorus.mac ];
				};
				aorus-hold = {
					name = "Keep aorus awake"; icon = "pause"; confirm = false; timeout = 15;
					command = aorus "hold";
				};
				aorus-release = {
					name = "Allow aorus to hibernate"; icon = "play"; confirm = false; timeout = 15;
					command = aorus "release";
				};
				aorus-hibernate = {
					name = "Hibernate aorus now"; icon = "moon"; unlock = true; timeout = 15;
					command = aorus "hibernate";
				};
				aorus-status = {
					name = "aorus status"; icon = "monitor"; confirm = false; timeout = 15;
					command = aorus "status";
				};
				ups-vars = {
					name = "Every variable"; icon = "terminal"; confirm = false; timeout = 10;
					command = [ "${pkgs.nut}/bin/upsc" "ups@localhost" ];
				};
				# For a Bluetooth link that doesn't come back by itself.
				nutflow-restart = {
					name = "Restart nutflow"; icon = "restart"; role = "admin"; timeout = 30;
					command = [ sudo "-n" "/run/current-system/sw/bin/systemctl" "restart" "nutflow.service" ];
				};
			};

			dashboards.dorm = {
				title = "Dorm";
				icon = "power";
				widgets = [
					{ type = "status"; value = "eco.status"; label = "EcoFlow"; icon = "power";
						caption = "{eco.status.since:duration} · {eco.status.flags}"; open = "ups.eco"; }
					{ type = "gauge"; value = "eco.battery.charge"; label = "Battery"; icon = "battery"; color = "battery";
						caption = "{eco.battery.runtime:duration}"; open = "ups.eco"; }
					{ type = "value"; value = "eco.input.realpower"; label = "Grid in"; icon = "bolt"; color = "rx"; span = 1; }
					{ type = "value"; value = "eco.ups.realpower"; label = "Output"; icon = "bolt"; color = "tx"; span = 1; }
					{ type = "value"; value = "eco.input.voltage"; label = "Grid"; icon = "bolt"; span = 1; empty = "none"; }
					{ type = "value"; value = "eco.battery.temperature"; label = "Battery"; icon = "thermometer"; span = 1; }
					{
						type = "group"; id = "aorus"; label = "aorus"; icon = "monitor";
						widgets = [
							(button "aorus-status" "Status" "monitor")
							(button "aorus-wake" "Wake" "bolt")
							(button "aorus-hold" "Keep awake" "pause")
							(button "aorus-release" "Allow hibernate" "play")
							(button "aorus-hibernate" "Hibernate now" "moon" // { span = 4; color = "hot"; })
						];
					}
					{
						type = "group"; id = "station"; label = "EcoFlow"; icon = "control";
						widgets = [
							# Minutes idle before AC 2 turns itself off; 0 is never.
							{ type = "select"; label = "AC 2 auto-off (min idle)"; span = 4;
								value = "eco.experimental.output.ac2.timeout";
								action = "nut.set.eco.experimental.output.ac2.timeout"; param = "value"; }
							(button "ups-vars" "Every variable" "terminal")
							(button "nutflow-restart" "Restart nutflow" "restart")
						];
					}
				];
			};

			# Power first: it is what this machine is for.
			profiles.default.dashboards = [ "dorm" "ups" "overview" "processes" "sensors" "control" ];
		};
	};
}
