#!/bin/sh
# Caffeine: inhibit idle (lock/dpms) by stopping hypridle. `status` feeds the
# waybar custom module; `toggle` is shared by the bar click and SUPER+I.

case "$1" in
status)
	if systemctl --user --quiet is-active hypridle; then
		printf '{"alt": "off", "class": "off"}\n'
	else
		printf '{"alt": "on", "class": "on"}\n'
	fi
	;;
toggle)
	if systemctl --user --quiet is-active hypridle; then
		systemctl --user stop hypridle
		msg="󰅶 Enabled"
	else
		systemctl --user start hypridle
		msg="󰾪 Disabled"
	fi
	id_file=${XDG_RUNTIME_DIR:-/tmp}/caffeine-notify-id
	id=$(cat "$id_file" 2>/dev/null)
	notify-send -p -u low -a caffeine ${id:+-r "$id"} "Caffeine" "$msg" > "$id_file"
	pkill -RTMIN+8 waybar
	;;
esac
