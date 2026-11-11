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
			mac = "10:ff:e0:c5:85:82";
			syncthing_id = "2RT4OHQ-IQGQ7U4-LYVSLOG-XFTHTOG-FGEKQ7W-JYLVK6L-PSGXMXS-NMP2YQL";
		};
		loq = {
			ts_ipv4 = "100.76.130.38";
			lan_ipv4 = "192.168.0.73";
			lan_wifi_ipv4 = "192.168.0.74";
			mac = "38:a7:46:49:fd:8e";
			syncthing_id = "FAGJ2ZS-NLCFK5F-7KWATND-MUBB6A3-QXRZ5II-NQSB7BY-URY3OST-JZGGXAI";
		};
		# Phones run sshd under termux: their own user, port 8022.
		rodin = {
			user = "u0_a319";
			port = 8022;
			syncthing_id = "C3BWTUT-GNGSXH5-ODQ435X-X3SENEF-MWSLEZO-PFMQWNV-N2FUKWT-EYXFQQB";
		};
		# postmarketOS since 2026-11-10 (generic qcom-msm8953 port, lk2nd in both
		# boot slots, rootfs in userdata; see pmos/) with the NixOS guest from
		# nix/hosts/tissot on top. Ethernet is a Realtek RTL8153 dongle on a
		# self-powered hub, Wi-Fi is the fallback; the Wi-Fi MAC is pinned in
		# the NetworkManager profile because wcn36xx has none of its own.
		tissot = {
			ts_ipv4 = "100.87.61.119";
			lan_ipv4 = "192.168.0.248";
			lan_wifi_ipv4 = "192.168.0.151";
			mac = "00:e0:4c:68:28:88";
			wifi_mac = "c6:7a:c0:e6:48:b7";
			# The NixOS guest's own sshd, beside the postmarketOS one on 22:
			# `ssh tissot-nix` (the ssh module makes the block).
			nix_port = 2222;
			# The EcoFlow as a NUT server (BLE daemon in the guest, :3493). The
			# login gates nothing: reads are open and the daemon takes no
			# commands, so it lives here rather than in sops.
			nut = { user = "monuser"; password = "monitor"; };
			# The dashboard's ssh identity, made on the phone on first boot
			# (hosts/tissot/power/dashboard.nix); aorus lets it in as power-remote.
			remote_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ00C/Q2kdzM2hDSFuhlfkxCiAn5jHpxQfmmpdloYb7l olivetin@tissot";
			# Identity generated on the phone itself (not in sops): a reinstall
			# means a new id here and re-pairing on the other peers.
			syncthing_id = "LYNYS7A-IFWCZOQ-WF2WD32-AJI53BX-TPZSGOV-XZNLHF2-HLBTVKY-IXV2CAK";
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
