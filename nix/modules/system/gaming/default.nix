# Steam, gamemode, sunshine streaming. GPU tuning is hardware knowledge - hosts
# set programs.gamemode.settings.gpu.
{ config, lib, pkgs, ... }:

{
	programs.gamemode.enable = true;

	# Sunshine streams the session to Moonlight clients. How to capture it is
	# desktop knowledge (../hyprland, ../gnome); the web UI origins are host
	# knowledge (nix/hosts/<host>/sunshine). Declaring apps here means the web UI
	# can't edit them and any local apps.json is ignored.
	services.sunshine = {
		enable = true;
		capSysAdmin = true; # kms capture needs it, wlr doesn't mind
		settings.upnp = "enabled";
		applications.apps =
			let
				virtualDisplay = config.dotfiles.sunshine.virtualDisplayPrep;

				steamBigPicture = {
					name = "Steam Big Picture";
					image-path = "steam.png";
					detached = [ "setsid steam steam://open/bigpicture" ];
					prep-cmd = [
						{
							do = "";
							undo = "setsid steam steam://close/bigpicture";
						}
					];
				};
			in
			[
				{
					name = "Desktop";
					image-path = "desktop.png";
				}
				steamBigPicture
			]
			# On a desktop that can (../hyprland): big picture again, but on the
			# virtual display at the client's resolution. undos run in reverse, so
			# the real monitors come back after steam closes.
			++ lib.optional (virtualDisplay != null) (steamBigPicture // {
				name = "Steam Big Picture (Virtual display)";
				prep-cmd = [ virtualDisplay ] ++ steamBigPicture.prep-cmd;
			});
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
