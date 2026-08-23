# Graphical session: Hyprland, ly, portals, audio, printing.
{ pkgs, ... }:

{
	programs.hyprland = {
		enable = true;
		withUWSM = true;
		xwayland.enable = true;
	};

	xdg.portal = {
		enable = true;
		extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
	};

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
			numlock = false;
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

	services.pipewire = { enable = true; pulse.enable = true; };
	services.printing.enable = true;

	programs.firefox.enable = true;
}
