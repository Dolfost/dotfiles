# Shared by every host.
{ config, lib, pkgs, ... }:

let
	user = config.dotfiles.user;
in
{
	imports = [ ./user.nix ];

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
	users.groups.${user}.gid = 1000;
	users.users.${user} = {
		isNormalUser = true;
		uid = 1000;
		group = user;
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
		# Entry point by convention: nix/home/<username>.nix. It pulls in
		# the shared baseline (core.nix); feature modules (desktop.nix,
		# gaming.nix) append their own home half, so hosts just pick modules.
		users.${user}.imports = [ (../home + "/${user}.nix") ];
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
