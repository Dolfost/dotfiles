{ lib, ... }: {
	networking.networkmanager.enable = true;
	# iwd instead of wpa_supplicant: impala drives iwd over D-Bus.
	networking.networkmanager.wifi.backend = "iwd";
	networking.wireless.iwd.enable = true;
	services.openssh.enable = true;
	services.tailscale = {
		enable = true;
		openFirewall = true;
		useRoutingFeatures = lib.mkDefault "client";
	};
}
