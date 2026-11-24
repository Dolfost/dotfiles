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
		./sunshine
		./ssh-chat
		./stickpile
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
		../../modules/system/ntfy
		../../modules/system/work
		../../modules/system/laptop
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
				# .7 first: the primary address is what the laptop sends to the radio's
				# ground unit from, and the unit delivers its TID / video to the address
				# that last talked to it on 14550 (the vendor test left .7 there, .68 was
				# the earlier value; docs/radio-link.md in auf)
				address1 = "192.168.144.7/24";
				address2 = "192.168.144.117/24";
				address3 = "10.0.0.5/24";
				address4 = "192.168.144.68/24";
				# the SIYI cameras' own subnet beside the lab LAN (auf docs/radio-link.md:
				# zr10_c .26, the second ZR10 .27; jet2 is .5) so the laptop reaches them
				# directly, the air unit's ONVIF scan does not
				address5 = "192.168.145.7/24";
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
	# `ntfy-cmd aorus-cmd wake|hold|release|hibernate|status` (modules/system/ntfy).
	dotfiles.ntfy.enable = true;

	system.stateVersion = "26.05";
}
