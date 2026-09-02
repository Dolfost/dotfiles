# Desktop audio effects. EasyEffects is its own DSP engine — the window
# is only a front-end — so it runs headless as a user service bound to
# graphical-session.target; launching the GUI attaches to that instance.
{ config, lib, ... }:

let
	link = path: {
		source = config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.dir}/${path}";
	};

	# <device>:<profile>.json, slashes flattened the way easyeffects does it.
	ruleFile = rule: lib.nameValuePair
		"easyeffects/autoload/${rule.kind}/${rule.device}:${
			lib.replaceStrings [ "/" ] [ "_" ] rule."device-profile"
		}.json"
		{ text = builtins.toJSON (removeAttrs rule [ "kind" ]); };
in
{
	options.dotfiles.audio = {
		enable = lib.mkOption {
			type = lib.types.bool;
			default = config.dotfiles.graphical;
			description = "PipeWire audio effects.";
		};

		autoload = lib.mkOption {
			type = lib.types.listOf lib.types.attrs;
			default = [ ];
			description = ''
				easyeffects autoload rules - which preset a device gets when it
				shows up. Devices are host hardware, so hosts declare these.
				Fields: kind ("input"/"output") plus easyeffects' own device,
				device-description, device-profile, preset-name.
			'';
		};
	};

	config = lib.mkIf config.dotfiles.audio.enable {
		services.easyeffects.enable = true;

		# Presets live in the repo — saving one from the GUI writes straight
		# into it. Autoload rules are generated from the host's declarations;
		# live state (db/) stays mutable in ~/.config/easyeffects.
		xdg.dataFile = {
			"easyeffects/output" = link "easyeffects/output";
			"easyeffects/input" = link "easyeffects/input";
		} // lib.listToAttrs (map ruleFile config.dotfiles.audio.autoload);
	};
}
