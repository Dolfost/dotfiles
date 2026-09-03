# Hyprland userland: bar, launcher, notifications.
{ osConfig ? { }, config, lib, pkgs, ... }:

let
	link = path: {
		source = config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.dir}/${path}";
	};

	apps = { inherit (pkgs) waybar fuzzel dunst; };

	# Everything the binds and scripts shell out to.
	tools = with pkgs; [
		hyprshot grim slurp # screenshots
		wl-clipboard cliphist # clipboard history
		hyprpicker # color picker
		jq libnotify # scripts: hyprctl parsing, notify-send
		playerctl brightnessctl # media keys, laptop backlight
		ddcutil # brightness.sh; i2c access comes from the openrgb host module
		yazi pulsemixer bluetui impala # bound TUIs
	];

	cfg = config.dotfiles.hyprland;
in
{
	options.dotfiles.hyprland = {
		enable = lib.mkOption {
			type = lib.types.bool;
			default = osConfig.programs.hyprland.enable or false;
			description = "Hyprland userland + config links. Follows the host's Hyprland on NixOS.";
		};

		localConfig = lib.mkOption {
			type = lib.types.lines;
			default = "";
			example = ''hl.monitor({ output = "DP-1", mode = "preferred" })'';
			description = "Machine-specific Lua run by load_local_config() after the shared hyprland.lua.";
		};

		secondaryDisplay = lib.mkOption {
			type = lib.types.lines;
			default = "";
			example = ''
				SECONDARY_MONITOR="HDMI-A-2"
				horizontal_args="mode='preferred', position='auto', disabled=false"
			'';
			description = ''
				Shell fragment sourced by toggle_secondary_display.sh: sets
				SECONDARY_MONITOR and <orientation>_args (horizontal, vertical,
				mirror) with hl.monitor args for this machine. Empty means the
				host has no toggleable secondary display.
			'';
		};
	};

	config = lib.mkIf cfg.enable {
		home.packages = lib.attrValues apps ++ tools;

		# Idle, wallpaper, night light and polkit daemons. Home-manager only
		# provides the user units here; settings stay empty on purpose so the
		# configs keep coming from the linked hypr directory.
		services.hypridle.enable = true;
		services.hyprpaper.enable = true;
		services.hyprsunset.enable = true;
		services.hyprpolkitagent.enable = true;

		xdg.configFile = lib.mapAttrs (name: _: link name) apps // {
			"hypr" = link "hypr";
			"uwsm" = link "uwsm";
		} // lib.optionalAttrs (cfg.localConfig != "") {
			"hypr-local/hyprland.lua".text = cfg.localConfig;
		} // lib.optionalAttrs (cfg.secondaryDisplay != "") {
			"hypr-local/secondary_display.sh".text = cfg.secondaryDisplay;
		};
	};
}
