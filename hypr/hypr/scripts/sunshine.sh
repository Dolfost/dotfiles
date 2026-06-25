#!/usr/bin/env bash
# toggle a Hyprland headless monitor for a Sunshine streaming session. bind in
# Sunshine's app config: do_cmd = "sunshine.sh start", undo_cmd = "sunshine.sh
# end".
HEADLESS=sunshine-headless
PHYSICAL_MONITORS=(DP-1 HDMI-A-2)

case "${1:-}" in
	start)
		echo 'start'
		width="${SUNSHINE_CLIENT_WIDTH:-1920}"
		height="${SUNSHINE_CLIENT_HEIGHT:-1080}"
		fps="${SUNSHINE_CLIENT_FPS:-60}"

		hyprctl eval "hl.monitor({output = \"${HEADLESS}\", mode = \"${width}x${height}@${fps}\", position = \"auto\", scale = 1, disabled = false})"
		for m in "${PHYSICAL_MONITORS[@]}"; do
			hyprctl eval "hl.monitor({output = \"${m}\", disabled = true})"
		done
		;;
	stop)
		echo 'stop'
		hyprctl eval "hl.monitor({output = \"${HEADLESS}\", disabled = true})"
		hyprctl reload
		;;
	*)
		echo "Usage: $0 {start|stop}" >&2
		exit 1
		;;
esac
