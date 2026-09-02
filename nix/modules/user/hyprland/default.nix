# Hyprland userland: bar, launcher, notifications.
{ osConfig ? { }, config, lib, pkgs, ... }:

let
	link = path: {
		source = config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.dir}/${path}";
	};

	apps = { inherit (pkgs) waybar fuzzel dunst; };

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
	};

	config = lib.mkIf cfg.enable {
		home.packages = lib.attrValues apps;

		xdg.configFile = lib.mapAttrs (name: _: link name) apps // {
			"hypr" = link "hypr";
		} // lib.optionalAttrs (cfg.localConfig != "") {
			"hypr-local/hyprland.lua".text = cfg.localConfig;
		};
	};
}
