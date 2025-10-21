#!/bin/sh

message() {
	notify-send -r 40238434 -u low -a dunst "Notifications" "$1"
}

if [ `dunstctl is-paused` = "false" ]; then 
	message "󰖁 Disabled"
	sleep 1
	dunstctl set-paused true
else
	message "󰕾 Enabled"
	dunstctl set-paused false
fi
