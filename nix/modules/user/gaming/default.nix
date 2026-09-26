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
			protonplus gpu-screen-recorder-gtk piper xbindkeys
		];
		xdg.configFile = { "MangoHud" = link "MangoHud"; } // envFiles;
		home.file.".local/bin/gscope" = link "bin/gscope";
		# Catches media keys that Steam Input chords inject via XTEST into
		# XWayland, where Hyprland binds can't see them (started in autostart.lua).
		home.file.".xbindkeysrc" = link "xbindkeys/xbindkeysrc";

		# The DualSense over USB doubles as a mic (two ridge mics, or the headset
		# jack - PipeWire swaps the source node). Sony's button-click suppression
		# runs on the PS5, so rnnoise stands in. The pad travels between hosts and
		# carries no USB serial, so these node names are the same on every machine.
		dotfiles.audio.autoload = [
			{
				kind = "input";
				device = "alsa_input.usb-Sony_Interactive_Entertainment_DualSense_Wireless_Controller-00.HiFi__Mic__source";
				"device-description" = "DualSense wireless controller (PS5) Internal Microphone";
				"device-profile" = "Internal Microphone";
				"preset-name" = "mic noise red | autogain | stereo";
			}
			{
				kind = "input";
				device = "alsa_input.usb-Sony_Interactive_Entertainment_DualSense_Wireless_Controller-00.HiFi__Headset__source";
				"device-description" = "DualSense wireless controller (PS5) Headset Microphone";
				"device-profile" = "Headset Microphone";
				"preset-name" = "mic noise red | autogain | stereo";
			}
		];

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
