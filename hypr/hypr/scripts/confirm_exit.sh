#!/bin/sh
# Exit Hyprland only on a double press: the first invocation arms a short
# window and notifies, a second one inside it exits.

flag=${XDG_RUNTIME_DIR:-/tmp}/hypr-exit-confirm
window=3
now=$(date +%s)

if [ -f "$flag" ] && [ $((now - $(cat "$flag"))) -le $window ]; then
	rm -f "$flag"
	hyprctl dispatch "hl.dsp.exit()"
	exit
fi

echo "$now" > "$flag"
notify-send -u critical -t $((window * 1000)) -a hyprland \
	'Exit Hyprland?' "Press again within ${window}s to exit"
