# Shared by every host.
{ lib, pkgs, ... }:

{
	nixpkgs.config.allowUnfree = true;
	nix.settings.experimental-features = [ "nix-command" "flakes" ];

	time.timeZone = "Europe/Kyiv";
	i18n.defaultLocale = "en_US.UTF-8";

	networking.networkmanager.enable = true;

	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	boot.kernelParams = [ "consoleblank=120" ];

	# uid and PRIMARY gid are pinned to match the Arch install on this machine.
	# NixOS would otherwise put a normal user in `users` (gid 100), and that
	# breaks rootless containers on shared storage
	users.groups.vladyslav.gid = 1000;
	users.users.vladyslav = {
		isNormalUser = true;
		uid = 1000;
		group = "vladyslav";
		# `users` is kept so files already written under gid 100 stay reachable.
		extraGroups = [ "users" "wheel" "networkmanager" ];
		shell = pkgs.zsh;
	};
	programs.zsh.enable = true;

	home-manager = {
		useGlobalPkgs = true;
		useUserPackages = false;
		startAsUserService = true;
		backupFileExtension = "hm-bak";
		users.vladyslav = import ../home/vladyslav.nix;
	};

	services.openssh.enable = true;
	services.tailscale = {
		enable = true;
		openFirewall = true;
		useRoutingFeatures = lib.mkDefault "client";
	};

	services.keyd = {
		enable = true;
		keyboards.default = {
			ids = [ "*" ];
			settings.main = {
				capslock = "esc";
				esc = "capslock";
			};
		};
	};

	environment.systemPackages = with pkgs; [
		neovim wget git tmux
	];
}
