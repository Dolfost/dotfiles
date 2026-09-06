{ config, lib, ... }: {
	home-manager.users.${config.dotfiles.user} = {
		# hyprlock never renders again after the dpms off->on
		# round-trip on this dual-AMD-GPU machine, so idle dpms/lock is
		# a black-screen lockout risk.
		services.hypridle.enable = lib.mkForce false;

		dotfiles = {
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
				hl.device({
					name = "logitech-g102-lightsync-gaming-mouse",
					sensitivity = -0.65,
				})
			'';

			# What SUPER+D/C/G toggle the TV into on this machine.
			hyprland.secondaryDisplay = ''
				SECONDARY_MONITOR="HDMI-A-2"
				horizontal_args="mode='3840x2160@60', position='2560x0', scale=1.333334, transform=0, disabled=false"
				vertical_args="mode='3840x2160@60', position='2560x-900', scale=1.333334, transform=3, disabled=false"
				mirror_args="mode='preferred', position='auto', scale=1, mirror='DP-1', disabled=false"
			'';
		};
	};
}
