# The ly display manager. Session-agnostic: it lists whatever sessions
# the other modules install (hyprland, gnome).
{ config, lib, ... }:

{
	# Unlock the gnome keyring with the login password on manual logins.
	# Autologin types no password, so those sessions rely on the login
	# keyring having a blank password instead.
	security.pam.services.ly.enableGnomeKeyring = true;

	# When hyprland is installed, boot straight into it. mkDefault so a host can
	# opt out.
	services.displayManager.autoLogin = lib.mkIf config.programs.hyprland.enable {
		enable = lib.mkDefault true;
		user = lib.mkDefault config.dotfiles.user;
	};
	services.displayManager.defaultSession =
		lib.mkIf config.programs.hyprland.enable (lib.mkDefault "hyprland-uwsm");

	services.displayManager.ly = {
		enable = true;
		settings = {
			animation = "none";
			asterisk = "*";
			auth_fails = 3;
			battery_id = "BAT1";

			bg = "0x00000000";
			fg = "0x00FFFFFF";
			border_fg = "0x00FFFFFF";
			error_bg = "0x00000000";
			error_fg = "0x01FF0000";
			full_color = true;

			bigclock = "none";
			blank_box = true;
			hide_borders = false;
			hide_key_hints = false;
			hide_keyboard_locks = false;
			hide_version_string = false;
			text_in_center = false;
			edge_margin = 0;
			margin_box_h = 2;
			margin_box_v = 1;
			input_len = 34;

			default_input = "password";
			clear_password = false;
			numlock = true;
			save = true;
			shell = true;
			lang = "en";

			vi_mode = false;
			vi_default_mode = "normal";

			shutdown_key = "F1";
			restart_key = "F2";
			sleep_key = "F3";
			hibernate_key = "F4";
			brightness_down_key = "F5";
			brightness_up_key = "F6";
			show_password_key = "F7";

			session_log = ".local/state/ly-session.log";
		};
	};
}
