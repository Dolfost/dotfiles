# Overlay config for games.
{ osConfig ? { }, config, lib, pkgs, ... }:

let
	link = config.lib.dotfiles.link;

	# gscope env files: repo-wide game defaults (games.nix), host defaults and
	# host game overrides (dotfiles.gaming.gscope.* set by the NixOS host).
	gscope = osConfig.dotfiles.gaming.gscope or { defaults = { }; games = { }; };

	# GSR save dirs: hosts know which disk has the space (dotfiles.gaming.gsr.* on the
	# NixOS host); anywhere else fall back to the home fallback.
	gsrFromHost = key: fallback:
		let host = (osConfig.dotfiles.gaming.gsr or { }).${key} or null;
		in if host == null then fallback else host;
	# lsfg-vk: Lossless Scaling frame generation as an implicit Vulkan layer.
	# Presets live in lsfg-vk/conf.toml in the repo (linked below, edits land in
	# git); bin/gscope exports LSFG_PROCESS (set per game in games.nix) to pick
	# one. Host opt-in (dotfiles.gaming.lsfg.enable) because of the DLL below.
	lsfgEnable = osConfig.dotfiles.gaming.lsfg.enable or false;

	# The frame-gen shaders live in the proprietary Windows app's Lossless.dll -
	# unredistributable, so it stays out of the repo and each host provides it
	# once: nix-store --add-fixed sha256 <path>. Linked to the stable home path
	# conf.toml names, which also keeps it alive across GC.
	losslessDll = pkgs.requireFile {
		name = "Lossless.dll";
		sha256 = "1szh3618qx3dnnxx39anrxqap4l64829xcmpa11cs1lng5nijsv2";
		message = ''
			Lossless.dll is proprietary (part of Lossless Scaling). Take it from a
			Steam install (steamapps/common/Lossless Scaling/Lossless.dll) or the
			LosslessScaling.tar.zst backup, then run:
				nix-store --add-fixed sha256 /path/to/Lossless.dll
		'';
	};

	globalGames = import ./games.nix;
	gameEnv = id: (globalGames.${id} or { }) // (gscope.games.${id} or { });
	envFile = attrs: {
		text = lib.concatStrings (lib.mapAttrsToList (k: v: "${k}=${toString v}\n") attrs);
	};
	envFiles =
		{
			# REPLAY_DIR bridges dotfiles.gaming.gsr.replayDir into bin/gscope's
			# replay buffer; explicit host defaults still win key-by-key.
			"gscope/default.env" = envFile ({
				REPLAY_DIR = config.dotfiles.gaming.gsr.replayDir;
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

	options.dotfiles.gaming.gsr = {
		recordDir = lib.mkOption {
			type = lib.types.str;
			default = gsrFromHost "recordDir" "${config.home.homeDirectory}/Videos";
			description = "Where GPU Screen Recorder saves recordings. Follows the host's dotfiles.gaming.gsr.recordDir on NixOS.";
		};
		replayDir = lib.mkOption {
			type = lib.types.str;
			default = gsrFromHost "replayDir" "${config.home.homeDirectory}/Videos/Replays";
			description = "Where GPU Screen Recorder saves replay clips. Follows the host's dotfiles.gaming.gsr.replayDir on NixOS.";
		};
	};

	config = lib.mkIf config.dotfiles.gaming.enable {
		home.packages = with pkgs; [
			protonplus gpu-screen-recorder-gtk piper
		] ++ lib.optional lsfgEnable lsfg-vk;
		xdg.configFile = { "MangoHud" = link "MangoHud"; } // envFiles
			// lib.optionalAttrs lsfgEnable { "lsfg-vk" = link "lsfg-vk"; };
		home.file = { ".local/bin/gscope" = link "bin/gscope"; }
			// lib.optionalAttrs lsfgEnable {
				".local/share/lossless-scaling/Lossless.dll".source = losslessDll;
			};

		# The GTK app rewrites its whole config file on every settings change, so
		# it can't be a store link. Nix owns only the save locations: each switch
		# re-pins the two keys, everything else stays GUI-managed.
		home.activation.gsrSaveDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
			gsrConfig="${config.xdg.configHome}/gpu-screen-recorder/config"
			run mkdir -p "$(dirname "$gsrConfig")" \
				"${config.dotfiles.gaming.gsr.recordDir}" "${config.dotfiles.gaming.gsr.replayDir}"
			run touch "$gsrConfig"
			run ${pkgs.gnused}/bin/sed -i \
				'/^record\.save_directory /d; /^replay\.save_directory /d' "$gsrConfig"
			run sh -c 'printf "%s\n" \
				"record.save_directory ${config.dotfiles.gaming.gsr.recordDir}" \
				"replay.save_directory ${config.dotfiles.gaming.gsr.replayDir}" >> '"\"$gsrConfig\""
		'';
	};
}
