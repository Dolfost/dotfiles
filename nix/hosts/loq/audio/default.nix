{ config, lib, ... }: {
	home-manager.users.${config.dotfiles.user}.dotfiles = {
		audio.autoload = [
			{
				kind = "input";
				"device" = "alsa_input.pci-0000_00_1f.3.analog-stereo";
				"device-description" = "Built-in Audio Analog Stereo";
				"device-profile" = "Internal Microphone";
				"preset-name" = "mic noise red | autogain | stereo";
			}
		];
	};
}
