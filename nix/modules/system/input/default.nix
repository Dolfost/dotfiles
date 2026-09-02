{ pkgs, ... }: {
	environment.systemPackages = [ pkgs.keyd ];

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
