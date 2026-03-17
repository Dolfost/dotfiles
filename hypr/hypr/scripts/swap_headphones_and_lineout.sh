#!/bin/sh 

# this file should define the 
#  mb --- motherboard sink name from pactl
#  dac --- dac sink name from pactl
source $(dirname $0)/swap_headphones_and_lineout_names.sh

message() {
	notify-send -r 42397454 -u low -a pactl "Audio output" "$1"
}

sink=$(pactl get-default-sink)

if [ "$second" != "" ]; then
	if [ "$sink" = "$second" ]; then
		pactl set-default-sink "$first"
		message "󱡬 Monitor"
	else
		pactl set-default-sink "$second"
		message "󱀞  DAC"
	fi
fi

echo "DAC is: $second"
echo "MB is:  $first"
