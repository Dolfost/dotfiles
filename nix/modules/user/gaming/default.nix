# Overlay config for games.
{ osConfig ? { }, config, lib, pkgs, ... }:

let
	link = config.lib.dotfiles.link;

	# gscope env files: repo-wide game defaults (games.nix), host defaults and
	# host game overrides (dotfiles.gscope.* set by the NixOS host).
	gscope = osConfig.dotfiles.gscope or { defaults = { }; games = { }; };
	globalGames = import ./games.nix;
	gameEnv = id: (globalGames.${id} or { }) // (gscope.games.${id} or { });
	envFile = attrs: {
		text = lib.concatStrings (lib.mapAttrsToList (k: v: "${k}=${toString v}\n") attrs);
	};
	envFiles =
		lib.optionalAttrs (gscope.defaults != { }) {
			"gscope/default.env" = envFile gscope.defaults;
		}
		// lib.listToAttrs (map (id: {
			name = "gscope/${id}.env";
			value = envFile (gameEnv id);
		}) (lib.attrNames (globalGames // gscope.games)));
in
{
	options.dotfiles.gaming.enable = lib.mkOption {
		type = lib.types.bool;
		default = osConfig.programs.steam.enable or false;
		description = "Gaming config links. Follows the host's Steam on NixOS.";
	};

	config = lib.mkIf config.dotfiles.gaming.enable {
		home.packages = [ pkgs.protonplus ];
		xdg.configFile = { "MangoHud" = link "MangoHud"; } // envFiles;
		home.file.".local/bin/gscope" = link "bin/gscope";
	};
}
