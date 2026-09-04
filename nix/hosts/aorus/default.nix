# Desktop. AMD, Hyprland, all the extra disks.
{ config, ... }:

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
		./sunshine

		# Baseline and the features this host opts into.
		../../modules/system
		../../modules/system/hyprland
		../../modules/system/gnome
		../../modules/system/ly
		../../modules/system/gaming
		../../modules/system/guitar
		../../modules/system/openrgb
		../../modules/system/amd-gpu
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


	# Gaming runs on the discrete AMD card (gpu_device 0 is the iGPU).
	programs.gamemode.settings.gpu = {
		apply_gpu_optimisations = "accept-responsibility";
		gpu_device = 1;
		amd_performance_level = "high";
	};

	# Network: this box routes for the tailnet and trusts its LAN.
	services.tailscale.useRoutingFeatures = "server";
	networking.firewall.enable = false;

	services.printing.enable = true;

	system.stateVersion = "26.05"; # DO NOT CHANGE
}
