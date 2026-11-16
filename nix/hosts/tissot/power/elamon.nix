# Elamon (github:Elaizes/elamon): the EcoFlow and aorus in the Elamon app
# on Android, beside the web dashboard (./dashboard.nix) and with the same
# things to do. elamond is a user service (ours, lingering), on :47823 for
# paired phones only (open on the host too, pmos/etc/nftables.d):
# `elamond pair` here prints the QR code.
#
# The phone is a small headless box that looks after other machines, so
# the app shows those and next to nothing of the phone itself. Three tabs,
# and no dashboards but theirs:
#   EcoFlow  everything of the station. It is elamond's standard UPS
#            dashboard (the status, a timeline of the outages, the outlets,
#            graphs that reach back, filled from upst's recorder for the
#            time before elamond, the switches and settings) without the
#            solar inputs, which nothing is plugged into.
#   aorus    whether it is up, on what power and whether it may hibernate,
#            what it draws, and what there is to do about it: wake, keep
#            awake, hibernate (the web dashboard's own script and ssh
#            identity, as olivetin).
#   Control  the phone in four lines, and the log of what phones did.
#
# elamond reads the station from nutflow like any NUT client, and may
# switch and set exactly what the web dashboard may (nutflow's
# control.allow there): AC 2, USB, the beeper, the charge limits, the
# charging power and the screen. AC 1 (aorus) and 12 V (the router) stay
# out of reach. It logs in to nutflow as the NUT user elamon, whose
# password is made here on first boot and never leaves the phone.
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
	# aorus.yaml of the web dashboard, and the units that show it in the app
	# (below): the link each is the unit of, and what its state reads as.
	aorusState = "/run/ups-state/aorus.yaml";
	marks = {
		up = { unit = "aorus-up.service"; label = "aorus"; active = "Up"; inactive = "Down (hibernated or off)"; warn = "inactive"; };
		battery = { unit = "aorus-on-battery.service"; label = "Power source"; active = "Battery"; inactive = "Grid"; warn = "active"; };
		hibernate = { unit = "aorus-auto-hibernate.service"; label = "Auto-hibernate"; active = "On"; inactive = "Held"; warn = "inactive"; };
	};
	mark = id: m: {
		id = "mark_${id}"; type = "status"; value = "link.aorus_${id}.unit_state"; inherit (m) label;
		map = { inherit (m) active inactive; }; levels.${m.warn} = "warning";
	};

	# elamond's standard dashboards, as it starts with them.
	standard = config.services.elamond.defaults.dashboards;
	# Its UPS dashboard is one per source ({item}); here it is the EcoFlow's.
	forEco = v:
		if lib.isString v then lib.replaceStrings [ "{item}" ] [ "eco" ] v
		else if lib.isList v then map forEco v
		else if lib.isAttrs v then lib.mapAttrs (_: forEco) v
		else v;
	# Left out: the solar inputs, and the settings the station has that
	# phones may not change (they would be left out anyway).
	unused = [ "solar" "solar1" "solar2" "xboost" "ac_timeout" ];
	trim = widgets: map
		(w: w // lib.optionalAttrs (w ? widgets) { widgets = trim w.widgets ++ (extra.${w.id or ""} or [ ]); })
		(lib.filter (w: !lib.elem (w.id or "") unused) widgets);
	# Its order, but what is looked at least last: the graphs, the details,
	# then nutflow's buttons and the station's settings, those one to a row
	# (their labels do not fit two columns).
	last = [ "charge_graph" "watts" "details" "nutflow" "station" ];
	arrange = widgets:
		lib.filter (w: !lib.elem w.id last) widgets
		++ map (id: let w = lib.findFirst (w: w.id == id) null widgets; in
			if id == "station" then w // { widgets = map (s: s // { span = 4; }) w.widgets; } else w) last;
	# Added to its groups, by id.
	extra.station = [
		# Minutes idle before AC 2 turns itself off; 0 is never.
		{ id = "ac2_timeout"; type = "select"; label = "AC 2 auto-off (min idle)";
			value = "eco.experimental.output.ac2.timeout";
			action = "nut.set.eco.experimental.output.ac2.timeout"; param = "value"; }
	];
in
{
	imports = [ inputs.elamon.nixosModules.default ];

	users.users.${user}.linger = true; # the service runs with nobody logged in

	services.nutflow.users.elamon = {
		passwordFile = nutflowPassword;
		allow = allowed;
	};

	# aorus's state, live in the app. elamond shows only its own readings and
	# a NUT source's, but among its own is the state of a systemd unit (of a
	# link, read every 5 s). So what the web dashboard knows about aorus
	# (aorus.yaml, every 10 s and after each button) is kept as three units
	# that do nothing but be active or not, and the tab shows their states.
	# While aorus is down the other two stay as they last were.
	systemd.services = lib.genAttrs (map (m: lib.removeSuffix ".service" m.unit) (lib.attrValues marks)) (unit: {
		description = "A mark for the Elamon app: ${unit}";
		serviceConfig = { Type = "oneshot"; RemainAfterExit = true; ExecStart = "${pkgs.coreutils}/bin/true"; };
		restartIfChanged = false;
		stopIfChanged = false;
	}) // {
		# The NUT user's password: made once, a copy for each side.
		nut-elamon-password = {
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
		aorus-marks = {
			description = "aorus's state as units, for the Elamon app";
			wantedBy = [ "multi-user.target" ];
			path = [ pkgs.gnused pkgs.systemd ];
			serviceConfig.Type = "oneshot";
			script = ''
				get() { sed -n "s/^  $1: \"\(.*\)\"$/\1/p" ${aorusState}; }
				mark() {
					unit=$1; shift
					if "$@"; then systemctl is-active -q "$unit" || systemctl start "$unit"
					else ! systemctl is-active -q "$unit" || systemctl stop "$unit"; fi
				}
				state=$(get state); source=$(get source)
				mark ${marks.up.unit} [ "$state" = up ]
				[ "$state" = up ] || exit 0
				mark ${marks.hibernate.unit} [ "$(get auto_hibernate)" = on ]
				mark ${marks.battery.unit} [ -n "$source" -a "$source" != - -a "$source" != grid ]
			'';
		};
	};
	systemd.paths.aorus-marks = {
		description = "aorus's state changed";
		wantedBy = [ "multi-user.target" ];
		pathConfig.PathChanged = aorusState;
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

			# Not pages to open (no widget lists them): each is here for its unit's
			# state, link.aorus_<id>.unit_state.
			links = lib.mapAttrs' (id: m: lib.nameValuePair "aorus_${id}" {
				name = m.label; url = "https://dash.${facts.ts_network}"; inherit (m) unit; scope = "system";
			}) marks;

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

			# These and no others: elamond's own (the overview of the computer,
			# processes, sensors and the pages they open) are left out.
			dashboards = lib.mkForce {
				# The chips under the name, on every tab.
				header = {
					title = "Header";
					widgets = [
						{ id = "status"; type = "status"; value = "eco.status"; }
						{ id = "charge"; type = "text"; text = "Battery {eco.battery.charge:percent}"; }
					];
				};

				ecoflow = {
					title = "EcoFlow";
					icon = "battery";
					widgets = arrange (trim (forEco standard.ups.widgets) ++ [{
						id = "nutflow"; type = "group"; label = "nutflow"; icon = "terminal";
						widgets = [
							(button "ups-vars" "Every variable" "terminal")
							(button "nutflow-restart" "Restart nutflow" "restart")
						];
					}]);
				};

				aorus = {
					title = "aorus";
					icon = "storage"; # the nearest elamond has to a server
					widgets = [
						(mark "up" marks.up // { span = 4; icon = "storage"; })
						(mark "battery" marks.battery)
						(mark "hibernate" marks.hibernate)
						# AC 1 is aorus and its screens, and nothing else.
						{ id = "draw"; type = "value"; value = "eco.outlet.1.realpower"; label = "Draws (AC 1)"; icon = "bolt"; color = "tx"; spark = true; }
						{ id = "left"; type = "value"; value = "eco.battery.runtime"; label = "EcoFlow lasts"; icon = "battery"; color = "battery"; }
						{
							id = "do"; type = "group"; label = "aorus"; icon = "storage";
							widgets = [
								(button "aorus-wake" "Wake" "bolt")
								(button "aorus-hold" "Keep awake" "pause")
								(button "aorus-release" "Allow hibernate" "play")
								(button "aorus-hibernate" "Hibernate now" "moon" // { span = 4; color = "hot"; })
							];
						}
						{ id = "draw_graph"; type = "graph"; values = [ "eco.outlet.1.realpower" ]; labels = [ "aorus" ];
							colors = [ "tx" ]; label = "Power"; icon = "bolt"; color = "tx"; min = 0; }
					];
				};

				control = {
					title = "Control";
					icon = "control";
					widgets = [
						{
							id = "tissot"; type = "list"; label = "tissot"; icon = "chip";
							items = [
								{ label = "Up"; value = "system.uptime"; }
								{ label = "Load"; text = "{cpu.load1:load}  {cpu.load5:load}  {cpu.load15:load}"; }
								{ label = "Memory"; text = "{mem.used:bytes} of {mem.total:bytes}"; }
								{ label = "System"; value = "system.os"; }
							];
						}
						{ id = "activity"; type = "button"; label = "Activity log"; icon = "clock"; open = "activity"; span = 4; role = "monitor"; }
					];
				};

				inherit (standard) activity;
			};

			profiles.default.dashboards = [ "ecoflow" "aorus" "control" ];

			# The paired phones, each with a profile of its own. elamond pair
			# writes a phone's table (its name and `use`) to
			# ~/.config/elamon/elamond.d/phones.toml, under the id it prints; what
			# the phone looks like is set here, under the same id.
			profiles.poco-x7-pro = {
				name = "POCO X7 Pro";
				use = "default";
				theme = "dark";
			};
		};
	};
}
