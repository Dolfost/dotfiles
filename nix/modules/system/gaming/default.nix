# Steam, gamemode, sunshine streaming. GPU tuning is hardware knowledge - hosts
# set programs.gamemode.settings.gpu.
{ pkgs, ... }:

{
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
		prismlauncher
	];
}
