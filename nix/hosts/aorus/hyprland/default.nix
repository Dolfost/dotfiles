{ config, lib, ... }: {
	home-manager.users.${config.dotfiles.user}.dotfiles = {
		# This machine's monitors.
		hyprland.localConfig = ''
			hl.monitor({
				output = "DP-1", mode = "2560x1440@180",
				position = "auto", scale = 1
			})
			hl.monitor({
				output = "HDMI-A-2", mode = "3840x2160@60",
				position = "2560x0", scale = 1, disabled = true
			})
		'';
	};
}
