#!/bin/sh 

# this file should define the 
#  mb --- motherboard sink name from pactl
#  dac --- dac sink name from pactl
source $(dirname $0)/swap_headphones_and_lineout_names.sh

message() {
	notify-send -u low -a pactl "Audio output" "$1"
}

sink=$(pactl get-default-sink)

if [ "$dac" != "" ]; then
	if [ "$sink" = "$dac" ]; then
		pactl set-default-sink "$mb"
		message "󱡬 Motherboard"
	else
		pactl set-default-sink "$dac"
		message "󱀞  DAC"
	fi
fi

echo "DAC is: $dac"
echo "MB is:  $mb"
