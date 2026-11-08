#!/usr/bin/env bash
# UPS pill for waybar: the charge, always. Plain on grid power, green while
# the UPS tops up, warning colours while the machine runs on it and danger
# near the low-battery action. Reads NUT's upsd on loopback
# (nix/modules/system/power); a host without one prints nothing, which hides
# the module.

command -v upsc > /dev/null 2>&1 || exit 0
data=$(upsc ups@localhost 2> /dev/null) || exit 0

get() { awk -F': ' -v key="$1" '$1 == key { print $2 }' <<< "$data"; }
status=$(get ups.status)
charge=$(get battery.charge)
runtime=$(get battery.runtime)
low=$(get battery.charge.low)
model=$(get device.model)
[ -n "$charge" ] || exit 0

case " $status " in
*" OB "*)
	class=battery
	icon=󰂃
	left=""
	if [ -n "$runtime" ] && [ "$runtime" -lt 86400 ]; then
		left=$(printf ', about %dh %02dm left' $((runtime / 3600)) $((runtime % 3600 / 60)))
	fi
	if [ -n "$low" ] && [ "$charge" -le $((low + 10)) ]; then class=low; fi
	tooltip="$model\n${charge}% on battery$left"
	;;
*" CHRG "*)
	class=charging
	icon=󰂄
	tooltip="$model\n${charge}%, charging"
	;;
*)
	class=online
	icon=󰚥
	tooltip="$model\n${charge}%, on grid power"
	;;
esac

printf '{"text": "%s %s%%", "class": "%s", "tooltip": "%s"}\n' "$icon" "$charge" "$class" "$tooltip"
