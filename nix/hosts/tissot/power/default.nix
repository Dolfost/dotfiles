# The EcoFlow Delta 3 Max Plus over Bluetooth, as the NUT server the whole
# network watches (upsc ups@tissot; aorus is a client of it, hosts/aorus/
# power). The server is nutflow (github:Dolfost/nutflow), which speaks the
# NUT protocol itself and asks the station for the grid readings every
# second. BlueZ lives on the host; the guest reaches it over the host's
# system bus, bound in at /run/host-dbus by the .nspawn unit. Root, because
# that is who the host's BlueZ policy lets through; nutflow keeps no
# capability as root.
#
# ./notify.nix turns its events into ntfy pushes; ./dashboard.nix has the
# buttons (through nutflow's control socket); upst's recorder keeps the
# history behind every upst dashboard on the network.
{ config, inputs, pkgs, ... }:

let
	facts = import ../../../facts.nix;
	hostBus = "/run/host-dbus/system_bus_socket";
in
{
	imports = [
		inputs.upst.nixosModules.default
		inputs.nutflow.nixosModules.default
		./notify.nix
		./dashboard.nix
	];

	# The EcoFlow account's user ID the station is bound to, from
	# nix/secrets-tissot.yaml: with it the pairing is fully local.
	sops.secrets."ecoflow/user_id" = { };

	services.nutflow = {
		enable = true;
		systemBusAddress = "unix:path=${hostBus}";
		user = "root";
		userIdFile = config.sops.secrets."ecoflow/user_id".path;
		stations = [{
			name = "ups";
			description = "EcoFlow Delta 3 Max Plus (BLE)";
			address = "D4:05:92:A3:F9:82";
			low_battery_percent = 20;
			# The device's remaining-time estimate is stale for the first seconds
			# on battery (2 min left at 93 %) and noisy after: a low one counts
			# only while discharging, at or below this charge, and once it has
			# held for the grace (LB from the charge threshold is immediate).
			low_runtime_seconds = 300;
			low_runtime_max_percent = 50;
			low_runtime_grace_seconds = 30;
			# The AC rating off the label: the unit does not report one over
			# Bluetooth, and ups.load is a share of this.
			rated_power_watts = 3000;
		}];
		# upsmon's login, here (./notify.nix) and on aorus (facts). It may do
		# nothing but log in, so the password gates nothing worth a secret:
		# not even FSD, which aorus's upsmon asks for before it hibernates and
		# goes on without.
		users.${facts.hosts.tissot.nut.user}.password = facts.hosts.tissot.nut.password;
		settings.nut.listen = [ "0.0.0.0:3493" ];
		# settings.control.allow: what the dashboard may do, ./dashboard.nix.
	};
	systemd.services.nutflow.unitConfig.ConditionPathExists = hostBus;

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

	environment.systemPackages = [ pkgs.nut ]; # upsc, to ask nutflow what it sees
}
