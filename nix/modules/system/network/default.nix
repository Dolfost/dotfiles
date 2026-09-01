{ lib, ... }: {
	networking.networkmanager.enable = true;
	services.openssh.enable = true;
	services.tailscale = {
		enable = true;
		openFirewall = true;
		useRoutingFeatures = lib.mkDefault "client";
	};
}
