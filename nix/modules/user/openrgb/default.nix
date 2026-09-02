# RGB device control. Devices are host hardware, so hosts declare the
# config dir (and ../../system/openrgb provides device access); nothing
# here turns on without it.
{ config, lib, pkgs, ... }:

let
	cfg = config.dotfiles.openrgb;
	link = path: {
		source = config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.dir}/${path}";
	};
in
{
	options.dotfiles.openrgb = {
		dir = lib.mkOption {
			type = lib.types.nullOr lib.types.str;
			default = null;
			description = ''
				Repo-relative directory with this host's OpenRGB config
				(profiles, settings). null leaves openrgb out entirely.
			'';
		};

		profile = lib.mkOption {
			type = lib.types.nullOr lib.types.str;
			default = null;
			description = "Name of an .orp profile in dir to apply at login.";
		};
	};

	config = lib.mkIf (cfg.dir != null) {
		home.packages = [ pkgs.openrgb ];
		xdg.configFile."OpenRGB" = link cfg.dir;

		systemd.user.services.openrgb-profile = lib.mkIf (cfg.profile != null) {
			Unit = {
				Description = "openrgb: apply the ${cfg.profile} profile";
				After = [ "graphical-session.target" ];
				PartOf = [ "graphical-session.target" ];
			};
			Service = {
				Type = "oneshot";
				RemainAfterExit = true;
				ExecStart = ''${pkgs.openrgb}/bin/openrgb -p "%h/.config/OpenRGB/${cfg.profile}.orp"'';
			};
			Install.WantedBy = [ "graphical-session.target" ];
		};
	};
}
