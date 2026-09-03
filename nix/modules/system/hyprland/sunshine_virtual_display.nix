# The Sunshine "Virtual display" prep script: stream on a headless output at
# the client's resolution with every real monitor off. autostart.lua
# pre-creates the sunshine-headless output; stop reloads the config to bring
# the real monitors back.
{ lib, pkgs }:
pkgs.writeShellScript "sunshine-virtual-display" ''
	HEADLESS=sunshine-headless

	case "''${1:-}" in
		start)
			width="''${SUNSHINE_CLIENT_WIDTH:-1920}"
			height="''${SUNSHINE_CLIENT_HEIGHT:-1080}"
			fps="''${SUNSHINE_CLIENT_FPS:-60}"

			hyprctl dispatch dpms on
			sleep 5s
			hyprctl eval "hl.monitor({output = \"$HEADLESS\", mode = \"''${width}x''${height}@''${fps}\", position = \"auto\", scale = 1, disabled = false})"
			for m in $(hyprctl monitors -j | ${lib.getExe pkgs.jq} -r '.[].name'); do
				[ "$m" = "$HEADLESS" ] && continue
				hyprctl eval "hl.monitor({output = \"$m\", disabled = true})"
			done
			;;
		stop)
			hyprctl eval "hl.monitor({output = \"$HEADLESS\", disabled = true})"
			hyprctl reload
			;;
		*)
			echo "Usage: $0 {start|stop}" >&2
			exit 1
			;;
	esac
''
