# Guitar rig: DAW, plugin host, and the plugins they load.
#
# carla/reaper find pipewire's libjack via LD_LIBRARY_PATH. The uwsm env
# bridge (system/hyprland) carries it into the session, but Hyprland's
# cap_sys_nice wrapper makes glibc scrub it on exec (nixpkgs#526193), so
# hl.env below re-injects it for everything Hyprland spawns.
{ osConfig ? { }, config, lib, pkgs, ... }:

let
	ratatouille = pkgs.callPackage ../../../packages/ratatouille.nix { };
	tone3000 = pkgs.callPackage ../../../packages/tone3000.nix { };
	pluginDir = fmt: "${config.home.profileDirectory}/lib/${fmt}";
	link = config.lib.dotfiles.link;
	# REAPER's resource path, where it looks for Scripts/.
	reaperDir =
		if pkgs.stdenv.isDarwin then "Library/Application Support/REAPER" else ".config/REAPER";
in
{
	options.dotfiles.guitar.enable = lib.mkOption {
		type = lib.types.bool;
		default = osConfig.services.pipewire.jack.enable or false;
		description = "Guitar rig. Follows the host's JACK support on NixOS.";
	};

	config = lib.mkMerge [ 
		( lib.mkIf config.dotfiles.guitar.enable {
			home.packages = with pkgs; [
				lsp-plugins
				calf
				guitarix              # also provides gxtuner.lv2
				neural-amp-modeler-lv2
				ratatouille
				tone3000
				dragonfly-reverb
				chow-centaur          # klon-style drive
				chow-tape-model
				chow-phaser
				airwindows-lv2
				# Windows VST2/VST3 plugins through wine. Install a plugin in the
				# prefix, then `yabridgectl add <its directory>` once and `yabridgectl
				# sync` after every install; the bridged .so files land in ~/.vst and
				# ~/.vst3.
				yabridge
				yabridgectl
			];
			dotfiles.hyprland.localConfig = ''
				hl.env("LD_LIBRARY_PATH", "${pkgs.pipewire.jack}/lib")
			'';

			# Plugins land in the nix profile, not /usr/lib - point the hosts at them.
			home.sessionVariables = {
				LV2_PATH = pluginDir "lv2";
				LADSPA_PATH = pluginDir "ladspa";
				VST3_PATH = pluginDir "vst3";
				CLAP_PATH = pluginDir "clap";
			};

			# Reaper reads only CLAP_PATH; its VST and LV2 scans use ~/.vst{,3}
			# and ~/.lv2 (or a path typed into its preferences). Link those at the
			# profile so every host sees the same plugins with no per-app setup.
			# Out-of-store so the links follow the profile across generations.
			home.file = lib.genAttrs [ ".vst" ".vst3" ".lv2" ] (dir: {
				source = config.lib.file.mkOutOfStoreSymlink
					(pluginDir (lib.removePrefix "." dir));
			});

			# TONE3000 reads factory presets from its config dir, next to the
			# user's own presets. Per-file links keep the rest of the tree writable.
			xdg.configFile."TONE3000/Presets/Factory" = {
				source = "${tone3000}/share/tone3000/factory-presets";
				recursive = true;
			};
		})

		( lib.mkIf config.dotfiles.graphical {
			home.packages = with pkgs; [
				carla
				reaper
				alsa-scarlett-gui
				sooperlooper          # looper; jack app, drive it from a footswitch
				tuxguitar             # plays guitar pro tabs
			];

			# Pedal scripts for REAPER (reaper/Scripts/amp-switch, one per F-key),
			# linked into its resource path so they show up under ReaScript: Load.
			# Key bindings stay out of the repo: REAPER rewrites reaper-kb.ini on
			# exit, so they are assigned once per machine in the action list.
			home.file."${reaperDir}/Scripts/amp-switch" = link "reaper/Scripts/amp-switch";
		})
	];
}
