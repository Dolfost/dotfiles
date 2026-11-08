#!/usr/bin/env bash
# Refresh rate picker for the focused monitor (SUPER + SHIFT + B): walker lists
# the rates its current resolution offers, highest first, and the pick is
# applied in place through hl.monitor with position, scale and transform kept
# - the same call the outage lever makes (nix/modules/user/power). Runtime
# only: the everyday mode stays in hypr-local, so a config reload puts it
# back. `refresh_rate.sh 120` skips the menu.
#
# walker --current wants an index and its base is unverified, so the current
# rate goes in the placeholder instead (same as pedal-mode).

notify() {
	local id_file=${XDG_RUNTIME_DIR:-/tmp}/refresh-rate-notify-id
	local id
	id=$(cat "$id_file" 2>/dev/null)
	notify-send -p -u low -a hyprctl ${id:+-r "$id"} "$@" > "$id_file"
}

mon=$(hyprctl monitors -j | jq -c '.[] | select(.focused)')
[ -n "$mon" ] || exit 1
IFS=$'\t' read -r name res pos scale transform mirror current < <(
	jq -r '[.name, "\(.width)x\(.height)", "\(.x)x\(.y)", .scale, .transform, .mirrorOf,
		(.refreshRate | round)] | @tsv' <<< "$mon"
)
rates=$(jq -r --arg res "$res@" '.availableModes[] | select(startswith($res))
	| sub("^.*@"; "") | sub("Hz$"; "") | tonumber | round' <<< "$mon" | sort -nru)

pick=${1-}
if [ -z "$pick" ]; then
	pick=$(walker --dmenu --placeholder "$name refresh rate (now: ${current} Hz)" <<< "$rates") || exit 0
	[ -n "$pick" ] || exit 0 # cancelled
fi
if ! grep -qx "$pick" <<< "$rates"; then
	echo "refresh_rate.sh [hz]; $name at $res offers: $(tr '\n' ' ' <<< "$rates")" >&2
	exit 1
fi

extra=""
[ "$mirror" = none ] || extra=", mirror='$mirror'"
if hyprctl eval "hl.monitor({output='$name', mode='${res}@${pick}', position='$pos', scale=$scale, transform=$transform$extra})" > /dev/null; then
	sleep 1 # the rule lands on the next frame
	now=$(hyprctl monitors -j | jq -r --arg n "$name" '.[] | select(.name == $n) | .refreshRate | round')
	notify "󰍹  " "$name at ${now} Hz"
else
	notify "󰍹  " "Could not set ${pick} Hz on $name"
	exit 1
fi
