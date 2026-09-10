{ ... }: {
	services.netbird.enable = true;
	networking.firewall.allowedUDPPorts = [ 35354 ];
}
