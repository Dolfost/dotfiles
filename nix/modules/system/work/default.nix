# Work: the auf ground station side. Everything that touches the DigiQ
# SkyPulse radio (video port, WireGuard through it) lives in ./wireguard.nix.
{ ... }: {
	imports = [ ./wireguard.nix ];

	services.netbird.enable = true;
	networking.firewall.allowedUDPPorts = [ 35354 ];
}
