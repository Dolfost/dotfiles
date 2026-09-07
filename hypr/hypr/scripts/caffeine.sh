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
		notify-send -r 40238435 -u low -a caffeine "Caffeine" "󰅶 Enabled"
	else
		systemctl --user start hypridle
		notify-send -r 40238435 -u low -a caffeine "Caffeine" "󰾪 Disabled"
	fi
	pkill -RTMIN+8 waybar
	;;
esac
