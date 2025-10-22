#!/bin/bash
# take an screenshot of the active window without border and rounding
# takes directory argument where to save

ACTIVE_WIN=$(hyprctl activewindow -j)
if [[ -z "$ACTIVE_WIN" ]]; then
    echo "No active window found."
    exit 1
fi

X=$(jq -r '.at[0]' <<< "$ACTIVE_WIN")
Y=$(jq -r '.at[1]' <<< "$ACTIVE_WIN")
W=$(jq -r '.size[0]' <<< "$ACTIVE_WIN")
H=$(jq -r '.size[1]' <<< "$ACTIVE_WIN")

ROUNDING=$(hyprctl getoption decoration:rounding -j | jq -r '.int')
BORDER=$(hyprctl getoption general:border_size -j | jq -r '.int')

echo "Active window at $X,$Y size ${W}x${H}"
echo "Current rounding=$ROUNDING border=$BORDER"

hyprctl keyword decoration:rounding 0
hyprctl keyword general:border_size 0

sleep 0.1

OUTFILE="$1/window_$(date +%F_%H-%M-%S).png"

if command -v grim >/dev/null; then
    grim -g "${X},${Y} ${W}x${H}" "$OUTFILE"
elif command -v hyprshot >/dev/null; then
    hyprshot -o "$OUTFILE" -m region -r "${X},${Y},${W},${H}"
else
    echo "Error: neither grim nor hyprshot found."
fi

hyprctl keyword decoration:rounding "$ROUNDING"
hyprctl keyword general:border_size "$BORDER"

echo "Screenshot saved to: $OUTFILE"

notify-send -a screenshot -u low "  window saved at" $OUTFILE
