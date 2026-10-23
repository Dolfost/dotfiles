# USB foot pedal for the guitar rig, plus keyd, the key remapper every keyboard
# on the host goes through (which is what lets the pedal be told apart from
# them by id).
#
# The pedal is a PCsensor-style switch that enumerates as a nameless "USB
# Keyboard"; footswitch programs what each switch types (F1..F12 here). It
# holds its key down for as long as the foot is on it, which the compositor
# turns into auto-repeat, so a REAPER action bound to it would fire over and
# over. keyd rewrites each F-key into a macro: press+release the moment the
# pedal goes down, nothing more until it comes up. The macro also carries
# Ctrl+Alt+Shift so the pedal collides with nothing a keyboard types (and Shift
# keeps Ctrl+Alt+Fn from reading as a VT switch).
#
# F13..F24 would be the obvious free keys, but they do not survive the trip:
# the default xkb map turns FK13..FK23 into XF86Tools/Launch/Touchpad keysyms,
# and REAPER's SWELL only translates F1..F12 to begin with.
{ config, lib, pkgs, ... }:

let
	cfg = config.dotfiles.pedal;
	fkeys = map (n: "f${toString n}") (lib.range 1 12);
in
{
	options.dotfiles.pedal = {
		id = lib.mkOption {
			type = lib.types.str;
			default = "04d9:1702";
			description = "The pedal's keyd device id, vendor:product, as `keyd monitor` prints it.";
		};
		keys = lib.mkOption {
			type = lib.types.listOf lib.types.str;
			default = map (key: "C-A-S-${key}") fkeys;
			description = "What the pedal's F1..F12 come out as, in order, as keyd macro expressions.";
		};
	};

	config = {
		environment.systemPackages = [ pkgs.footswitch ];
		services.udev.packages = [ pkgs.footswitch ];

		services.keyd = {
			enable = true;
			# An explicit id outranks ../input's wildcard config.
			keyboards.pedal = {
				ids = [ cfg.id ];
				settings = {
					# A held macro key starts repeating after this; at ~25 days it never
					# does.
					global.macro_timeout = 2147483647;
					main = lib.listToAttrs (lib.zipListsWith
						(from: to: lib.nameValuePair from "macro(${to})") fkeys cfg.keys);
				};
			};
		};
	};
}
