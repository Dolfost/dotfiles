#!/bin/sh
# Unified brightness control for laptops and desktops: adjusts the internal
# panel (brightnessctl) if present, plus every DDC-capable external monitor
# (ddcutil). DDC buses are detected once and cached, because `ddcutil detect`
# takes seconds; the cache lives in XDG_RUNTIME_DIR so it resets on login. Run
# `brightness.sh refresh` after plugging/unplugging monitors.
#
# Usage: brightness.sh <command>
#   max | min                 set brightness to maximum / minimum
#   small-inc | small-dec     +-1%
#   inc | dec                 +-5%
#   large-inc | large-dec     +-10%
#   refresh                   re-detect DDC monitors

small_step=1
step=5
large_step=10

cache=${XDG_RUNTIME_DIR:-/tmp}/ddc-buses

detect_buses() {
	# skip "Invalid display" sections: eDP panels and other non-DDC outputs
	ddcutil detect -t 2>/dev/null | awk '
		/^Display /{ok=1} /^Invalid display/{ok=0}
		ok && /I2C bus:/{sub(".*\\/dev\\/i2c-", ""); print}' > "$cache"
}

case $1 in
	max)       bctl='100%';            ddc="100"           ;;
	min)       bctl='0%';              ddc="0"             ;;
	small-inc) bctl="${small_step}%+"; ddc="+ $small_step" ;;
	small-dec) bctl="${small_step}%-"; ddc="- $small_step" ;;
	inc)       bctl="${step}%+";       ddc="+ $step"       ;;
	dec)       bctl="${step}%-";       ddc="- $step"       ;;
	large-inc) bctl="${large_step}%+"; ddc="+ $large_step" ;;
	large-dec) bctl="${large_step}%-"; ddc="- $large_step" ;;
	refresh)   detect_buses; exit                          ;;
	*)         sed -n '2,15p' "$0"; exit 1                 ;;
esac

value= # resulting percent, shown as the notification progress bar

# internal panel
if command -v brightnessctl >/dev/null && [ -n "$(ls /sys/class/backlight 2>/dev/null)" ]; then
	brightnessctl set "$bctl" >/dev/null
	value=$(( $(brightnessctl get) * 100 / $(brightnessctl max) ))
fi

# external DDC monitors, all in parallel
if command -v ddcutil >/dev/null; then
	[ -f "$cache" ] || detect_buses
	ddc_cmd='ddcutil --noverify --sleep-multiplier .1'
	for bus in $(cat "$cache" 2>/dev/null); do
		$ddc_cmd --bus "$bus" setvcp 0x10 $ddc 2>/dev/null &
	done
	wait
	if [ -z "$value" ]; then
		bus=$(head -n1 "$cache" 2>/dev/null)
		[ -n "$bus" ] && value=$($ddc_cmd --bus "$bus" getvcp 0x10 -t 2>/dev/null | awk '{print $4}')
	fi
fi

[ -n "$value" ] && notify-send -u low -a brightness -h int:value:"$value" -r 7423790 '󰃝  Brightness'
