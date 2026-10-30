{ pkgs, inputs, ... }:

let
	unstable = import inputs.nixpkgs-unstable {
		system = pkgs.stdenv.hostPlatform.system;
		config.allowUnfree = true;
	};
in
{
	imports = [
		./hardware-configuration.nix
		./storage
		./audio
		./ssh
		./hyprland
		./syncthing
		./ssh-chat
		../../modules/system
		../../modules/system/nvidia-gpu
		../../modules/system/hyprland
		../../modules/system/gnome
		../../modules/system/ly
		../../modules/system/gaming
		../../modules/system/media
		../../modules/system/pedal
		../../modules/system/diy
		../../modules/system/openrgb
		../../modules/system/android
		../../modules/system/work
	];

	# linuxPackages_zen tracks the newest zen release even on the stable
	# branch, but the stable branch's nvidia driver lags behind it (26.05's
	# 595.71.05 does not compile against linux 7.2). Take the whole kernel
	# package set from unstable so kernel and nvidiaPackages move together
	# and are both built by hydra.
	boot.kernelPackages = unstable.linuxPackages_zen;

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
				address1 = "192.168.144.117/24";
				address2 = "10.0.0.5/24";
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
