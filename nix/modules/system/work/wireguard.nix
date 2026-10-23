# Peers: generate a key on the device (air/daemon/share/air/system/wireguard/
# install.sh in the auf repo, deployed under share/air/, prints it) and add it
# here with the next 10.144.0.x/32. Keys live in sops (nix/secrets.yaml ->
# wg_skypulse/*):
{ config, pkgs, ... }:
let
	# the TID port registered on units
	wg_port = 55555;
in
{
	environment.systemPackages = [ pkgs.wireguard-tools ];

	sops.secrets."wg_skypulse/loq_key" = { };

	networking.firewall.allowedUDPPorts = [
		5600    # radio video output (RTP) -> ground app
		wg_port # wireguard through the radio's TID
	];
	# the tunnel itself is trusted end to end (daemon TCP 35353, ssh, ...)
	networking.firewall.trustedInterfaces = [ "wg-sky" ];

	networking.wireguard.interfaces.wg-sky = {
		ips = [ "10.144.0.1/24" ];
		listenPort = wg_port;
		mtu = 1300; # the radio drops datagrams near full size (vendor example)
		privateKeyFile = config.sops.secrets."wg_skypulse/loq_key".path;
		peers = [
			{
				publicKey = "WOi3aHI/B3VQ1yRQQ5giOGs3+OsaCqFNA2IJALujACQ=";
				allowedIPs = [ "10.144.0.2/32" ];
				endpoint = "192.168.144.2:${toString wg_port}";
				persistentKeepalive = 15;
			}
		];
	};
}
