{ pkgs, ... }: {
	environment.systemPackages = [ pkgs.keyd ];

	# Graphical sessions keep the numlock LED dark via an xkb indicator override
	# (xkb/compat/lednum, linked by modules/user); this covers the console and
	# the ly greeter, whose VT keyboard drives LEDs through the kbd-* led-class
	# triggers. Numlock itself stays on — only the light dies.
	services.udev.extraRules = ''
		ACTION=="add", SUBSYSTEM=="leds", KERNEL=="input*::numlock", ATTR{trigger}="none", ATTR{brightness}="0"
	'';

	# The Lofree Flow Lite fakes Apple ids (05ac:024f), so hid_apple drives it
	# and its default fnmode treats the F row as media keys with fn doing
	# nothing. 2 = F-keys primary, fn+F for the media layer.
	boot.extraModprobeConfig = "options hid_apple fnmode=2";

	services.keyd = {
		enable = true;
		keyboards.default = {
			ids = [ "*" ];
			settings.main = {
				capslock = "esc";
				esc = "capslock";
			};
		};
	};
}
