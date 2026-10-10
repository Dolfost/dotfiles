# Messengers. The terminal client (tgt) is always on so a headless home still
# has Telegram; the GUI messengers follow dotfiles.graphical.
{ config, lib, pkgs, inputs, ... }:

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
	tgt = inputs.tgt.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
	options.dotfiles.communication.enable = lib.mkOption {
		type = lib.types.bool;
		default = true;
		description = "Messengers. Terminal client everywhere, GUI ones only on graphical hosts.";
	};

	config = lib.mkIf config.dotfiles.communication.enable (lib.mkMerge [
		{ home.packages = [ tgt ]; }

		(lib.mkIf config.dotfiles.graphical {
			home.packages = with pkgs; [
				ayugram-desktop
				viber
			]
			++ map pinSecretStore (with pkgs; [
				vesktop
				signal-desktop
			]);
		})
	]);
}
