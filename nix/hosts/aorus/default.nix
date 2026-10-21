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
		./printing

		# Baseline and the features this host opts into.
		../../modules/system
		../../modules/system/hyprland
		../../modules/system/gnome
		../../modules/system/ly
		../../modules/system/gaming
		../../modules/system/media
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

	dotfiles.gaming.gscope.defaults = {
		GAMESCOPE = 0;
		MANGOHUD_EXTRA = "gpu_list=0"; # show only discrete graphics
		REPLAY = 180; # rolling clip buffer for every game; ALT+SHIFT+6 saves
	};

	dotfiles.gaming.gsr = {
		recordDir = "/storage/3.5/recordings";
		replayDir = "/storage/3.5/replays";
	};
	dotfiles.media.recordDir = "/storage/3.5/recordings";

	# The POCO X7 Pro as a webcam over Wi-Fi. Give it a DHCP reservation on the
	# router or this goes stale; `phone-cam usb` for the cable.
	dotfiles.android.phoneCam.address = "192.168.0.175";

	# Network: this box routes for the tailnet and trusts its LAN.
	services.tailscale.useRoutingFeatures = "server";
	# Volz routes customer-to-customer traffic without CGNAT, so a Moonlight
	# client on another Volz line reaches this box with a 100.64.0.0/10 source
	# on enp10s0. tailscaled's ts-input chain drops those as spoofed tailnet
	# addresses, which killed Sunshine (public IP or tailnet) from such sites.
	# nodivert builds the chains but never hooks them; safe here because this
	# box advertises no subnet routes and is not an exit node.
	services.tailscale.extraSetFlags = [ "--netfilter-mode=nodivert" ];
	networking.firewall.enable = false;

	networking.interfaces.enp10s0.wakeOnLan.enable = true;

	networking.networkmanager.ensureProfiles.profiles = {
		wired = {
			connection = {
				id = "wired";
				type = "ethernet";
				interface-name = "enp10s0";
				autoconnect-priority = 10;
			};
			ipv4 = {
				method = "auto";
				address1 = "192.168.144.66/24";
			};
			ipv6.method = "auto";
		};
	};

	system.stateVersion = "26.05"; # DO NOT CHANGE
}
