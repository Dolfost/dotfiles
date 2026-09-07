# The dotfiles.* vocabulary, declared once and imported into both evals: the
# system baseline (..) and the home side (../../user). The graphical default
# only means something in the system eval (a home config has no
# programs.hyprland, so the `or false` fallbacks leave it off); the baseline
# forwards the host's value into the embedded home, and a standalone home
# flips it by hand.
{ lib, config, ... }:

{
	options.dotfiles = {
		graphical = lib.mkOption {
			type = lib.types.bool;
			default = (config.programs.hyprland.enable or false)
				|| (config.services.desktopManager.gnome.enable or false);
			description = "This home sits on a host with a graphical session; the GUI app groups follow it.";
		};
		user = lib.mkOption {
			type = lib.types.str;
			default = "vladyslav";
			description = "Login name of the primary account.";
		};
		dir = lib.mkOption {
			type = lib.types.str;
			default = "/home/${config.dotfiles.user}/dotfiles";
			description = "The one checkout all config links point at, whoever's home this is.";
		};
		# Cross-feature contract: the desktop module that knows how to move the
		# session onto a virtual display at the client's resolution (../hyprland)
		# publishes its Sunshine prep-cmd here; consumers (../gaming's Steam Big
		# Picture) pick it up without depending on the desktop module.
		sunshine.virtualDisplayPrep = lib.mkOption {
			type = with lib.types; nullOr (attrsOf str);
			default = null;
			description = "Sunshine prep-cmd ({ do, undo }) that streams on a virtual display, if this host's desktop can.";
		};
	};
}
