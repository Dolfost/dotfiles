# Desktop. AMD, Hyprland, all the extra disks.
{ ... }:

{
	imports = [
		./hardware-configuration.nix
		../../modules/common.nix
		../../modules/desktop.nix
		../../modules/storage.nix
	];

	networking.hostName = "aorus";

	# Always-on box on the LAN, so it ADVERTISES routes rather than only using
	# them. Overrides the mkDefault "client" in modules/common.nix.
	services.tailscale.useRoutingFeatures = "server";

	services.displayManager = {
		autoLogin = {
			enable = true;
			user = "vladyslav";
		};
		defaultSession = "hyprland-uwsm";
	};

	# Trusted LAN only. Deliberately NOT in common.nix — the laptop keeps the
	# default firewall ON, since it leaves the house.
	networking.firewall.enable = false;

	# The release this host was INSTALLED with. Not the release it runs.
	system.stateVersion = "26.05"; # DO NOT CHANGE
}
