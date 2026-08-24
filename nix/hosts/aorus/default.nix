# Desktop. AMD, Hyprland, all the extra disks.
{ ... }:

let
	facts = import ./facts.nix;
in
{
	imports = [
		./hardware-configuration.nix
		./services.nix
		../../modules/common.nix
		../../modules/desktop.nix
		../../modules/storage.nix
	];

	networking.hostName = facts.hostName;

	services.tailscale.useRoutingFeatures = "server";

	services.displayManager = {
		autoLogin = {
			enable = true;
			user = "vladyslav";
		};
		defaultSession = "hyprland-uwsm";
	};

	networking.firewall.enable = false;

	system.stateVersion = "26.05"; # DO NOT CHANGE
}
