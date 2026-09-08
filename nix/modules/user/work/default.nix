{ osConfig ? { }, config, lib, pkgs, ... }:
let
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
	options.dotfiles.work.enable = lib.mkOption {
		type = lib.types.bool;
		# GUI-only apps: stay off on headless machines even when they run netbird.
		default = config.dotfiles.graphical && (osConfig.services.netbird.enable or false);
		description = "Work apps. Follows the host's netbird on NixOS.";
	};

	config = lib.mkIf config.dotfiles.work.enable {
		home.packages = [ (pinSecretStore pkgs.element-desktop) ];
	};
}
