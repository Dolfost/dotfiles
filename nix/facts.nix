# The personal network, described once. Every machine on the tailnet /
# wireguard gets an entry; the tailscale name is always "d" + the machine name
# (aorus -> daorus). Hosts read their own entry (facts.hosts.aorus), the ssh
# module reads the whole fleet.
let
	# syncthing_id is the device's syncthing identity, derived from its keypair.
	# For the NixOS hosts the keypair lives in sops (nix/secrets.yaml under
	# syncthing/<name>/cert + key) and is installed on every start, so the id
	# survives reinstalls. New machine: `syncthing generate` anywhere, record the
	# printed id here, `sops` the two pem files in.
	machines = {
		aorus = {
			ts_ipv4 = "100.91.220.75";
			lan_ipv4 = "192.168.0.70";
			syncthing_id = "2RT4OHQ-IQGQ7U4-LYVSLOG-XFTHTOG-FGEKQ7W-JYLVK6L-PSGXMXS-NMP2YQL";
		};
		loq = {
			ts_ipv4 = "100.76.130.38";
			lan_ipv4 = "192.168.0.73";
			lan_wifi_ipv4 = "192.168.0.74";
			syncthing_id = "FAGJ2ZS-NLCFK5F-7KWATND-MUBB6A3-QXRZ5II-NQSB7BY-URY3OST-JZGGXAI";
		};
		# Phones run sshd under termux: their own user, port 8022.
		rodin = {
			user = "u0_a319";
			port = 8022;
			syncthing_id = "C3BWTUT-GNGSXH5-ODQ435X-X3SENEF-MWSLEZO-PFMQWNV-N2FUKWT-EYXFQQB";
		};
		tissot = {
			user = "u0_a181";
			port = 8022;
		};
		# Not managed from here; only a syncthing peer.
		mac = {
			syncthing_id = "46KBBNV-OAK4LJA-2FX7BNV-EIXWRIW-XTLQSTM-PE4GJB5-EPIV33Q-64B5BQ7";
		};
	};
in
{
	ts_network = "faun-castor.ts.net";
	hosts = builtins.mapAttrs
		(name: machine: machine // { ts_hostname = "d" + name; })
		machines;
}
