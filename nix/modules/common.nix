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

	users.users.vladyslav = {
		isNormalUser = true;
		extraGroups = [ "wheel" "networkmanager" ];
		shell = pkgs.zsh;
	};
	programs.zsh.enable = true;

	home-manager = {
		# true, not false: home-manager reuses the system's nixpkgs instead of
		# instantiating a second one. Without this it never sees the
		# `allowUnfree` above and claude-code fails to evaluate.
		useGlobalPkgs = true;
		useUserPackages = false;
		startAsUserService = true;
		# Move pre-existing files aside instead of aborting activation.
		backupFileExtension = "hm-bak";
		users.vladyslav = import ../home/vladyslav.nix;
	};

	services.openssh.enable = true;
	services.tailscale = {
		enable = true;
		openFirewall = true;
		# "client" = may USE exit nodes / subnet routes. mkDefault so a host can
		# override it with a plain assignment in its own default.nix (see aorus).
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

	# git is required, not optional: a flake only sees git-TRACKED files.
	environment.systemPackages = with pkgs; [
		neovim wget git
	];
}
