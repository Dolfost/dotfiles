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
			animation = "matrix";
			hide_borders = true;
			clock = "%c";
			bigclock = "en";
			hide_key_hints = true;
		};
	};

	services.pipewire = { enable = true; pulse.enable = true; };
	services.printing.enable = true;

	programs.firefox.enable = true;
}
