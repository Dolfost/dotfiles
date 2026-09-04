{ config, ... }: {
	home-manager.users.${config.dotfiles.user}.dotfiles = {
		# This machine's input devices: the external mouse a notch slower than the
		# shared input defaults, the touchpad faster and adaptive - flat accel
		# feels sluggish on a pad, and input.touchpad has no accel/sensitivity
		# overrides, so per-device by exact name.
		hyprland.localConfig = ''
			hl.device({
				name = "logitech-g102-lightsync-gaming-mouse",
				sensitivity = -0.3,
			})
			hl.device({
				name = "elan06fa:00-04f3:327e-touchpad",
				sensitivity = 0.25,
				accel_profile = "adaptive",
			})
		'';
	};
}
