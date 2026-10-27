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
#
# Modes (pedal-mode.sh, SUPER + Z in Hyprland): the chords serve both the
# desktop and REAPER, Hyprland decides which by binding them or not. Games want
# a real held key instead, identical to the keyboard's (one bind per action),
# and only keyd can produce that. The macros therefore live in a layout named
# `pedal` rather than in main: `keyd bind` applies an expression to every
# loaded config, but `pedal.f1 = w` is refused wherever that layer does not
# exist, so it rebinds the pedal alone. The socket is root-only unless the
# `keyd` group exists, in which case keyd hands it to that group; whoever is in
# it can bind command() actions, i.e. is root on this host.
{ config, lib, pkgs, ... }:

let
cfg = config.dotfiles.pedal;
fkeys = map (n: "f${toString n}") (lib.range 1 12);
pedal-mode = pkgs.writeShellApplication {
	name = "pedal-mode";
	runtimeInputs = [ pkgs.keyd ];
	text = builtins.readFile ./pedal-mode.sh;
};
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
		games = lib.mkOption {
			type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
# The four pedals wired so far are F7, F8, F9, F10, left to right.
			default = {
				walk = { f7 = "w"; };
				dst = { f7 = "space"; }; # Don't Starve Together
			};
			description = ''
				Game profiles for `pedal-mode game <name>`: pedal F-key to the plain
				key it holds down while stepped on, in keyd's names (`keyd list-keys`).
				'';
		};
	};

	config = {
		environment.systemPackages = [ pkgs.footswitch pedal-mode ];
		services.udev.packages = [ pkgs.footswitch ];

		users.groups.keyd = { };
		users.users.${config.dotfiles.user}.extraGroups = [ "keyd" ];
		# keyd setgid()s to that group before creating the socket and exits on
		# failure; the NixOS unit's bounding set has no CAP_SETGID, so without this
		# the service dies with status 255 once the group exists.
		systemd.services.keyd.serviceConfig.CapabilityBoundingSet = [ "CAP_SETGID" ];

		environment.etc = lib.mapAttrs'
			(name: keys: lib.nameValuePair "pedal-mode/games/${name}" {
			 text = lib.concatLines (lib.mapAttrsToList (key: to: "${key} = ${to}") keys);
			 })
		cfg.games;

		services.keyd = {
			enable = true;
# An explicit id outranks ../input's wildcard config.
			keyboards.pedal = {
				ids = [ cfg.id ];
				settings = {
					global = {
# A held macro key starts repeating after this; at ~25 days it never
# does.
						macro_timeout = 2147483647;
						default_layout = "pedal";
					};
					main = { };
					"pedal:layout" = lib.listToAttrs (lib.zipListsWith
							(from: to: lib.nameValuePair from "macro(${to})") fkeys cfg.keys);
				};
			};
		};
	};
}
