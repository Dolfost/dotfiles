# Workbench apps: electronics and mechanical design. The bench itself (serial
# ports, programmers) is modules/system/diy, and importing that is what turns
# this on for a NixOS host.
{ osConfig ? { }, config, lib, pkgs, ... }:

{
	options.dotfiles.diy.enable = lib.mkOption {
		type = lib.types.bool;
		default = config.dotfiles.graphical && (osConfig.dotfiles.diy.enable or false);
		description = "Electronics and CAD apps. Follows the host's diy module on NixOS.";
	};

	config = lib.mkIf config.dotfiles.diy.enable {
		home.packages = with pkgs; [
			# Schematics, PCB layout, and the simulator (ngspice is built in).
			# The full build carries the 3D models; kicad-small drops them, and
			# with them the board viewer and the STEP export that hands a board
			# to FreeCAD, for about 400 MiB saved.
			kicad
			# Parametric CAD: enclosures, panels, anything that gets drilled or
			# printed.
			freecad
			# Code-first CAD for the quick brackets and spacers. Plain `openscad`
			# is still the 2021 release; this is the current snapshot with the
			# manifold backend.
			openscad-unstable
		];
	};
}
