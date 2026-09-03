# Desktop. AMD, Hyprland, all the extra disks.
{ config, lib, ... }:

let
	facts = import ./facts.nix;
in
{
	imports = [
		# What this machine is.
		./hardware-configuration.nix
		./storage
		./services
		./coolercontrol
		./audio
		./hyprland
		./openrgb
		./lact

		# Baseline and the features this host opts into.
		../../modules/system
		../../modules/system/hyprland
		../../modules/system/gnome
		../../modules/system/ly
		../../modules/system/gaming
		../../modules/system/guitar
		../../modules/system/openrgb
		../../modules/system/amd
		../../modules/system/android
	];

	# Session: boot straight into Hyprland.
	services.displayManager = {
		autoLogin = {
			enable = true;
			user = config.dotfiles.user;
		};
		defaultSession = "hyprland-uwsm";
	};


	# Gaming runs on the discrete AMD card (gpu_device 0 is the iGPU); sunshine
	# streams to the tailnet/VPN addresses.
	programs.gamemode.settings.gpu = {
		apply_gpu_optimisations = "accept-responsibility";
		gpu_device = 1;
		amd_performance_level = "high";
	};
	services.sunshine.settings.csrf_allowed_origins =
		lib.concatMapStringsSep "," (h: "https://${h}:47990") [
			"${facts.ts_hostname}.${facts.ts_network}"
			"${facts.ts_hostname}.wg"
			"10.8.0.4"
		];

	# Network: this box routes for the tailnet and trusts its LAN.
	services.tailscale.useRoutingFeatures = "server";
	networking.firewall.enable = false;

	services.printing.enable = true;

	system.stateVersion = "26.05"; # DO NOT CHANGE
}
