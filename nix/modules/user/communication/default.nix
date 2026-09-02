{ config, lib, pkgs, ... }:

let
	# Chromium doesn't recognise Hyprland as a desktop it knows a keyring
	# for and falls back to plaintext storage; signal then refuses to open
	# its database. Point every bundled binary at the keyring explicitly -
	# the .desktop entries launch by bare name, so they hit these wrappers.
	pinSecretStore = pkg: pkgs.symlinkJoin {
		inherit (pkg) name;
		paths = [ pkg ];
		nativeBuildInputs = [ pkgs.makeWrapper ];
		postBuild = ''
			for bin in $out/bin/*; do
				wrapProgram "$bin" --add-flags --password-store=gnome-libsecret
			done
		'';
	};
in
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
		++ map pinSecretStore (with pkgs; [
			discord
			signal-desktop
			element-desktop
		]);
	};
}
