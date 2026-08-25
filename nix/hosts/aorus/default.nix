# Desktop. AMD, Hyprland, all the extra disks.
{ config, lib, mods, ... }:

let
	facts = import ./facts.nix;
in
{
	imports = [
		./hardware-configuration.nix
		./storage.nix
		./services.nix
		./coolercontrol.nix
		mods.common
		mods.desktop
		mods.gaming
	];

	services.sunshine.settings.csrf_allowed_origins =
		lib.concatMapStringsSep "," (h: "https://${h}:47990") [
			"${facts.tsHostName}.${facts.tailnet}"
			"${facts.tsHostName}.wg"
			"10.8.0.4"
		];

	networking.hostName = facts.hostName;

	services.tailscale.useRoutingFeatures = "server";

	# gpu_device 1 is the discrete AMD card (0 is the iGPU).
	programs.gamemode.settings.gpu = {
		apply_gpu_optimisations = "accept-responsibility";
		gpu_device = 1;
		amd_performance_level = "high";
	};

	services.displayManager = {
		autoLogin = {
			enable = true;
			user = config.dotfiles.user;
		};
		defaultSession = "hyprland-uwsm";
	};

	networking.firewall.enable = false;

	system.stateVersion = "26.05"; # DO NOT CHANGE
}
