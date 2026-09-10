#!/bin/sh
# hyprshot wrapper: silences its generic notification and sends one that
# names the capture type (Screen / Window / Region) with an image preview.
#
# Usage: screenshot.sh <output|window|region> [dir]

mode=$1
dir=${2:-$HOME/Pictures/Screenshots}

case $mode in
	output) label='Screen'; extra='-m active' ;;
	window) label='Window'; extra='-m active' ;;
	region) label='Region'; extra=''          ;;
	*)      sed -n '2,5p' "$0"; exit 1        ;;
esac

file="$label $(date '+%Y-%m-%d at %H.%M.%S').png"
hyprshot -s -m "$mode" $extra -o "$dir" -f "$file"
# no file means the selection was cancelled: stay quiet
[ -f "$dir/$file" ] || exit 0
notify-send -u low -a screenshot -i "$dir/$file" \
	"󰹑  $label screenshot" "Saved and copied to clipboard"
