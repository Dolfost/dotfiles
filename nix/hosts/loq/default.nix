{ ... }: {
	imports = [
		./hardware-configuration.nix
		./storage
		./audio
		./ssh
		./hyprland
		./syncthing
		../../modules/system
		../../modules/system/nvidia-gpu
		../../modules/system/hyprland
		../../modules/system/gnome
		../../modules/system/ly
		../../modules/system/gaming
		../../modules/system/openrgb
		../../modules/system/android
		../../modules/system/work
	];

	services.power-profiles-daemon.enable = true;
	hardware.bluetooth.powerOnBoot = true;

	networking.interfaces.enp7s0.wakeOnLan.enable = true;

	networking.networkmanager.ensureProfiles.profiles = {
		wired = {
			connection = {
				id = "wired";
				type = "ethernet";
				interface-name = "enp7s0";
				autoconnect-priority = 10;
			};
			ipv4 = {
				method = "auto";
				address1 = "192.168.144.68/24";
			};
			ipv6.method = "auto";
		};
		wired-static = {
			connection = {
				id = "wired-static";
				type = "ethernet";
				interface-name = "enp7s0";
				autoconnect = false;
			};
			ipv4 = {
				method = "manual";
				address1 = "192.168.144.68/24";
			};
			ipv6.method = "disabled";
		};
	};

	# Set this to the release you actually install with, then never change it.
	system.stateVersion = "26.05";
}
