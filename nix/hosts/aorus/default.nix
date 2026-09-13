# Desktop. AMD, Hyprland, all the extra disks.
{ ... }:

{
	imports = [
		# What this machine is.
		./hardware-configuration.nix
		./storage
		./services
		./ssh
		./coolercontrol
		./audio
		./hyprland
		./openrgb
		./lact
		./sunshine
		./syncthing

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
		../../modules/system/work
	];

	programs.gamemode.settings.gpu = {
		apply_gpu_optimisations = "accept-responsibility";
		gpu_device = 1;
		amd_performance_level = "high";
	};

	dotfiles.gscope.defaults = {
		GAMESCOPE = 0;
		MANGOHUD_EXTRA = "gpu_list=0"; # show only discrete graphics
		REPLAY = 180; # rolling clip buffer for every game; ALT+SHIFT+6 saves
	};

	dotfiles.gsr = {
		recordDir = "/storage/3.5/recordings";
		replayDir = "/storage/3.5/replays";
	};

	# Network: this box routes for the tailnet and trusts its LAN.
	services.tailscale.useRoutingFeatures = "server";
	networking.firewall.enable = false;

	networking.interfaces.enp10s0.wakeOnLan.enable = true;

	services.printing.enable = true;

	system.stateVersion = "26.05"; # DO NOT CHANGE
}
