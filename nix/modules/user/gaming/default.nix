# Overlay config for games.
{ osConfig ? { }, config, lib, pkgs, ... }:

let
	link = config.lib.dotfiles.link;

	# gscope env files: repo-wide game defaults (games.nix), host defaults and
	# host game overrides (dotfiles.gscope.* set by the NixOS host).
	gscope = osConfig.dotfiles.gscope or { defaults = { }; games = { }; };

	# GSR save dirs: hosts know which disk has the space (dotfiles.gsr.* on the
	# NixOS host); anywhere else fall back to the home fallback.
	gsrFromHost = key: fallback:
		let host = (osConfig.dotfiles.gsr or { }).${key} or null;
		in if host == null then fallback else host;
	globalGames = import ./games.nix;
	gameEnv = id: (globalGames.${id} or { }) // (gscope.games.${id} or { });
	envFile = attrs: {
		text = lib.concatStrings (lib.mapAttrsToList (k: v: "${k}=${toString v}\n") attrs);
	};
	envFiles =
		{
			# REPLAY_DIR bridges dotfiles.gsr.replayDir into bin/gscope's replay
			# buffer; explicit host defaults still win key-by-key.
			"gscope/default.env" = envFile ({
				REPLAY_DIR = config.dotfiles.gsr.replayDir;
			} // gscope.defaults);
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

	options.dotfiles.gsr = {
		recordDir = lib.mkOption {
			type = lib.types.str;
			default = gsrFromHost "recordDir" "${config.home.homeDirectory}/Videos";
			description = "Where GPU Screen Recorder saves recordings. Follows the host's dotfiles.gsr.recordDir on NixOS.";
		};
		replayDir = lib.mkOption {
			type = lib.types.str;
			default = gsrFromHost "replayDir" "${config.home.homeDirectory}/Videos/Replays";
			description = "Where GPU Screen Recorder saves replay clips. Follows the host's dotfiles.gsr.replayDir on NixOS.";
		};
	};

	config = lib.mkIf config.dotfiles.gaming.enable {
		home.packages = [ pkgs.protonplus pkgs.gpu-screen-recorder-gtk ];
		xdg.configFile = { "MangoHud" = link "MangoHud"; } // envFiles;
		home.file.".local/bin/gscope" = link "bin/gscope";

		# The GTK app rewrites its whole config file on every settings change, so
		# it can't be a store link. Nix owns only the save locations: each switch
		# re-pins the two keys, everything else stays GUI-managed.
		home.activation.gsrSaveDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
			gsrConfig="${config.xdg.configHome}/gpu-screen-recorder/config"
			run mkdir -p "$(dirname "$gsrConfig")" \
				"${config.dotfiles.gsr.recordDir}" "${config.dotfiles.gsr.replayDir}"
			run touch "$gsrConfig"
			run ${pkgs.gnused}/bin/sed -i \
				'/^record\.save_directory /d; /^replay\.save_directory /d' "$gsrConfig"
			run sh -c 'printf "%s\n" \
				"record.save_directory ${config.dotfiles.gsr.recordDir}" \
				"replay.save_directory ${config.dotfiles.gsr.replayDir}" >> '"\"$gsrConfig\""
		'';
	};
}
