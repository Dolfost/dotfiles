{ ... }: {
	imports = [
		./hardware-configuration.nix
		./storage
		./audio
		./ssh
		./hyprland
		../../modules/system
		../../modules/system/nvidia-gpu
		../../modules/system/hyprland
		../../modules/system/gnome
		../../modules/system/ly
		../../modules/system/gaming
		../../modules/system/openrgb
		../../modules/system/android
	];

	services.power-profiles-daemon.enable = true;
	hardware.bluetooth.powerOnBoot = true;

	# Set this to the release you actually install with, then never change it.
	system.stateVersion = "26.05";
}
