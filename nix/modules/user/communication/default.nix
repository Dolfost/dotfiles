{ config, lib, pkgs, ... }:

{
	options.dotfiles.communication.enable = lib.mkOption {
		type = lib.types.bool;
		default = config.dotfiles.graphical;
		description = "Messengers.";
	};

	config = lib.mkIf config.dotfiles.communication.enable {
		home.packages = with pkgs; [
			telegram-desktop
			viber
		]
		# Chromium doesn't recognise Hyprland as a desktop it knows a keyring
		# for and falls back to plaintext storage; signal then refuses to
		# open its database. Point them at the keyring explicitly.
		++ map (p: p.override {
			commandLineArgs = "--password-store=gnome-libsecret";
		}) (with pkgs; [
			discord
			signal-desktop
			element-desktop
		]);
	};
}
