# Guitar rig: DAW, plugin host, and the plugins they load.
#
# carla/reaper find pipewire's libjack via LD_LIBRARY_PATH. The uwsm env
# bridge (system/hyprland) carries it into the session, but Hyprland's
# cap_sys_nice wrapper makes glibc scrub it on exec (nixpkgs#526193), so
# hl.env below re-injects it for everything Hyprland spawns.
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

		dotfiles.hyprland.localConfig = ''
			hl.env("LD_LIBRARY_PATH", "${pkgs.pipewire.jack}/lib")
		'';

		# Plugins land in the nix profile, not /usr/lib - point the hosts at them.
		home.sessionVariables = {
			LV2_PATH = "${config.home.profileDirectory}/lib/lv2";
			LADSPA_PATH = "${config.home.profileDirectory}/lib/ladspa";
			VST3_PATH = "${config.home.profileDirectory}/lib/vst3";
		};
	};
}
