# Guitar rig: DAW, plugin host, and the plugins they load.
#
# carla/reaper find pipewire's libjack via the session-wide LD_LIBRARY_PATH
# from environment.sessionVariables; the uwsm env bridge in system/hyprland
# carries it (and the plugin paths below) into the graphical session.
{ osConfig ? { }, config, lib, pkgs, ... }:

{
	options.dotfiles.guitar.enable = lib.mkOption {
		type = lib.types.bool;
		default = osConfig.services.pipewire.jack.enable or false;
		description = "Guitar rig. Follows the host's JACK support on NixOS.";
	};

	config = lib.mkIf config.dotfiles.guitar.enable {
		home.packages = with pkgs; [
			carla
			reaper
			lsp-plugins
			calf
			guitarix              # also provides gxtuner.lv2
			neural-amp-modeler-lv2
			(callPackage ../../../packages/ratatouille.nix { })
			dragonfly-reverb
		];

		# Plugins land in the nix profile, not /usr/lib - point the hosts at them.
		home.sessionVariables = {
			LV2_PATH = "${config.home.profileDirectory}/lib/lv2";
			LADSPA_PATH = "${config.home.profileDirectory}/lib/ladspa";
			VST3_PATH = "${config.home.profileDirectory}/lib/vst3";
		};
	};
}
