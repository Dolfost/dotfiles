# The EcoFlow Delta 3 Max Plus over Bluetooth, as the NUT server the whole
# network watches (upsc ups@tissot; aorus is a client of it, hosts/aorus/
# power). The daemon is a Go program speaking the NUT protocol itself, from
# my fork until upstream merges the extra variables (packages/
# ecoflow-ble-nutd.nix). BlueZ lives on the host; the guest reaches it over
# the host's system bus, bound in at /run/host-dbus by the .nspawn unit.
# Root, because that is who the host's BlueZ policy lets through.
#
# ./notify.nix turns its events into ntfy pushes; upst's recorder keeps the
# history behind every upst dashboard on the network.
{ config, inputs, pkgs, ... }:

let
	facts = import ../../../facts.nix;
	ecoflow-ble-nutd = pkgs.callPackage ../../../packages/ecoflow-ble-nutd.nix { };

	# The daemon's config, rendered by sops-nix at activation with the EcoFlow
	# app login from nix/secrets-tissot.yaml (the user_id makes the BLE
	# pairing fully local; email/password would resolve it at startup). The
	# YAML is generated from this attrset; the placeholders are swapped for
	# the secrets in the rendered file under /run/secrets, never in the store.
	ecoflowConfig = (pkgs.formats.yaml { }).generate "ecoflow-ble-nutd.conf" {
		listen = "0.0.0.0:3493";
		# The NUT login (facts: reads need none and the daemon takes no
		# control commands, so it gates nothing worth a secret).
		auth = { username = facts.hosts.tissot.nut.user; password = facts.hosts.tissot.nut.password; };
		provider = {
			type = "eco-ble";
			adapter = "hci0";
			scan_timeout_seconds = 8;
			connect_timeout_seconds = 20;
			reconnect_delay_seconds = 10;
			poll_seconds = 15;
			auth = {
				# Set once known and the cloud login is skipped for good.
				user_id = config.sops.placeholder."ecoflow/user_id";
				email = config.sops.placeholder."ecoflow/email";
				password = config.sops.placeholder."ecoflow/password";
				region = "auto";
			};
		};
		web = { enable = true; listen = "127.0.0.1:8081"; };
		devices = [{
			name = "ups";
			description = "EcoFlow Delta 3 Max Plus (BLE)";
			model = "DELTA 3 Max Plus";
			mac = "D4:05:92:A3:F9:82";
			low_battery_percent = 20;
			# The device's remaining-time estimate is stale for the first seconds
			# on battery (2 min left at 93 %) and noisy after: a low one counts
			# only while discharging, at or below this charge, and once it has
			# held for the grace (LB from the charge threshold is immediate).
			low_runtime_seconds = 300;
			low_runtime_max_percent = 50;
			low_runtime_grace_seconds = 30;
			stale_timeout_seconds = 120;
			# The AC rating off the label: the unit does not report one over
			# Bluetooth, and ups.load is a share of this.
			rated_power_watts = 3000;
		}];
	};
in
{
	imports = [
		inputs.upst.nixosModules.default
		./notify.nix
		./dashboard.nix
	];

	sops.secrets = {
		"ecoflow/email" = { };
		"ecoflow/password" = { };
		"ecoflow/user_id" = { };
	};
	sops.templates."ecoflow-ble-nutd.conf" = {
		file = ecoflowConfig;
		mode = "0400";
		restartUnits = [ "ecoflow-ble-nutd.service" ];
	};

	systemd.services.ecoflow-ble-nutd = {
		description = "EcoFlow Delta 3 Max Plus over BLE as a NUT server";
		wantedBy = [ "multi-user.target" ];
		after = [ "network.target" ];
		unitConfig.ConditionPathExists = "/run/host-dbus/system_bus_socket";
		environment.DBUS_SYSTEM_BUS_ADDRESS = "unix:path=/run/host-dbus/system_bus_socket";
		serviceConfig = {
			ExecStart = "${ecoflow-ble-nutd}/bin/ecoflow-ble-nutd -config ${config.sops.templates."ecoflow-ble-nutd.conf".path}";
			Restart = "on-failure";
			RestartSec = 30;
			ProtectSystem = "strict";
			ProtectHome = true;
			PrivateTmp = true;
		};
	};

	# upst's recorder: the history behind every upst dashboard on the
	# network (aorus points its upst here). The journals live in
	# /var/lib/upst; :3494 is open on the host firewall for remote upst.
	services.upst = {
		enable = true;
		settings = {
			targets = [ "ups@localhost" ];
			record = {
				interval = "5s";
				keep = "7d";
				listen = [ "/run/upst/upst.sock" "0.0.0.0:3494" ];
			};
		};
	};

	environment.systemPackages = [ pkgs.nut ]; # upsc, to ask the daemon what it sees
}
