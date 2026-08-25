{ config, pkgs, ... }:

{
	imports = [ ./user.nix ];

	home-manager.users.${config.dotfiles.user}.imports = [
		../home/gaming.nix
	];

	# GPU tuning is hardware knowledge — hosts set programs.gamemode.settings.gpu.
	programs.gamemode.enable = true;

	services.sunshine = {
		enable = true;
		capSysAdmin = true;
		settings = {
			capture = "wlr";
			upnp = "enabled";
		};
	};

	programs.steam = {
		enable = true;
		extraPackages = [ pkgs.mangohud ];
	};

	environment.systemPackages = with pkgs; [
		mangohud
		adwsteamgtk
	];
}
