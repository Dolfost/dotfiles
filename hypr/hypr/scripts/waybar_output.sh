#!/bin/sh
# One waybar instance per monitor (waybar@<output>.service): SIGUSR1 toggles a
# whole waybar process, so hiding the bar on a single monitor needs one process
# per output. `run` (the unit's ExecStart) pins the shared config to one
# output; `toggle` hides/shows the bar on the focused monitor (SUPER+Y).

case "$1" in
run)
	# waybar merges `include` under the including file, so `output` wins
	config=${XDG_RUNTIME_DIR:-/tmp}/waybar-$2.jsonc
	printf '{ "output": ["%s"], "include": ["%s"] }\n' \
		"$2" "$HOME/.config/waybar/config.jsonc" > "$config"
	exec waybar -c "$config" -s "$HOME/.config/waybar/style.css"
	;;
toggle)
	focused=$(hyprctl monitors -j | jq -r '.[] | select(.focused).name')
	# main only: the default whom=all would also hit module children
	# (swaync-client), for which unhandled USR1 is fatal
	systemctl --user kill -s USR1 --kill-whom=main "waybar@$focused.service"
	;;
esac
