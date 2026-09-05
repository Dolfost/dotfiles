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
	];

	# Nested gamescope is broken on this machine in every GPU mode (hybrid:
	# cross-GPU judder / gamescope#2081; MUX discrete: sluggish mouse), and the
	# laptop panel gains nothing from it - run games direct.
	dotfiles.gscope.defaults.GAMESCOPE = 0;

	services.power-profiles-daemon.enable = true;
	hardware.bluetooth.powerOnBoot = true;

	# Set this to the release you actually install with, then never change it.
	system.stateVersion = "26.05";
}
